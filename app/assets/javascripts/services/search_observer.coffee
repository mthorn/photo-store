@app.factory 'SearchObserver', [
  '$location',
  ($location) ->

    class SearchObserver

      constructor: (scope, defaults) ->
        if ! (@ instanceof SearchObserver)
          return new SearchObserver(scope, defaults)

        @scope = scope
        @defaults = defaults
        @watches = []
        @keys = _.keys @defaults

        @types = {}
        for key, val of @defaults
          if angular.isNumber(val)
            @types[key] = 'number'
          else if angular.isString(val)
            @types[key] = 'string'
          else if val == true || val == false
            @types[key] = 'boolean'
          else if angular.isUndefined(val)
            delete @defaults[key]

        scope.$on '$routeUpdate', @updateAndNotify
        scope.$on '$routeChangeSuccess', @updateAndNotify

        @params()

      # Get/set all params
      params: (params) ->
        if arguments.length == 1
          @$lastAppliedParams = params
          search = @paramsToSearch(params)

          currentAll = $location.search()
          currentOwn = @$lastAppliedSearch ? _.pick(currentAll, @keys)
          if angular.equals(search, currentOwn)
            $location
          else
            @$lastAppliedSearch = search
            # add other values that are already in search that this instance is not observing
            $location.search(angular.extend({}, search, _.omit(currentAll, @keys)))
        else
          # shallow copy
          angular.extend({}, @$params ?= @searchToParams($location.search()))

      # Get/set single param. Leaves other param values as is.
      param: (name, value) ->
        if arguments.length == 2
          params = @$lastAppliedParams ? @params()
          if angular.isDefined value
            params[name] = value
          else
            delete params[name]
          @params(params)
        else
          @$params ?= @searchToParams($location.search())
          @$params[name]

      paramsToSearch: (params, options = {}) ->
        search = angular.copy params

        # delete default values from search, unless option to keep them is set
        if options.defaults != true
          for key, def of @defaults
            delete search[key] if angular.equals(search[key], def)

        # normalize non-string values
        omit = options.omit ? []
        for key, val of search
          if angular.isUndefined(val) || key in omit
            delete search[key]
          else if ! val?
            search[key] = ''
          else if ! angular.isString(val)
            switch @types[key]
              when 'boolean'
                search[key] = (if val then 't' else 'f')
              else
                search[key] = "#{val}"

        search

      searchToParams: (search, options = {}) ->
        params = {}
        angular.extend(params, @defaults) unless options.defaults == false
        angular.extend(params, _.pick(search, @keys))

        # convert strings values to required types
        for key, type of @types
          if angular.isString(val = params[key]) && type != 'string'
            params[key] =
              switch type
                when 'number' then parseInt(val)
                when 'boolean' then val == 't'
                else val

        params

      updateAndNotify: =>
        last = @$params
        @$params = null

        current = @params()
        for [ params, listener ] in @watches
          if _.some(params, (param) -> current[param] != last[param])
            listener(current, last)
        undefined

      observe: (params, options, listener) ->
        if arguments.length == 2
          listener = options
          options = {}

        if params == '*'
          @watches.push([ @keys, listener ])
        else if angular.isString(params)
          @watches.push([ _.words(params, /[\w*]+/g), listener ])
        else
          @watches.push([ params, listener ])

        listener(@params(), @params()) unless options.initial == false
        @

      bindTo: (@$bindObject) ->
        @

      bindParam: (name, options = {}) ->
        bindProperty = options.to ? name
        @observe(name, (params) => @$bindObject[bindProperty] = params[name])
        @scope.$watch((=> @$bindObject[bindProperty]), ((next, prev) =>
          sameAsLast = angular.equals(next, prev)
          sameAsSearch = angular.equals(next, @params()[name])
          return if sameAsLast && sameAsSearch
          @param(name, next)
          $location.replace() if options.onUpdate == 'replace'
        ), true)
        @

      bindAll: (name) ->
        @observe('*', (params) => @$bindObject[name] = params)
        @scope.$watch((=> @$bindObject[name]), ((next, prev) =>
          return if angular.equals(next, prev)
          @params(next || {})
        ), true)
        @
]
