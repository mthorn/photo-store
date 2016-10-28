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

      params: (params) ->
        if arguments.length == 1
          params = angular.copy params

          # delete default values from params
          for key, def of @defaults
            delete params[key] if params[key] == def

          # normalize non-string values
          for key, val of params
            if angular.isUndefined(val)
              delete params[key]
            else if ! val?
              params[key] = ''
            else if @types[key] == 'boolean'
              params[key] = (if val then 'true' else 'false')
            else if ! angular.isString(val)
              params[key] = "#{val}"

          # add other values that are already in search that this instance is not observing
          current = $location.search()
          angular.extend(params, _.omit(current, @keys))

          if angular.equals(params, current)
            $location
          else
            $location.search(params)
        else
          if ! @$params?
            @$params = angular.extend({}, @defaults, _.pick($location.search(), @keys))

            # convert strings values to required types
            for key, type of @types
              if angular.isString(val = @$params[key]) && type != 'string'
                @$params[key] =
                  switch type
                    when 'number' then parseInt(val)
                    when 'boolean' then val == 'true'
                    else val

          angular.copy @$params

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
