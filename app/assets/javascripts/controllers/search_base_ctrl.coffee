class @SearchBaseCtrl extends BaseCtrl
  @inject '$location'

  constructor: (args...) ->
    super(args...)

    for name, fn of @
      if angular.isFunction(fn)
        if (m = name.match(/^\$searchChange\((.+)\)$/))
          @$searchWatchers.push([ _.words(m[1], /[\w*]+/g), (fn = fn.bind(@)) ])
          fn(@search(), @search())

  initSearch: (@$searchDefaults) ->
    @$searchTypes = {}
    for key, val of @$searchDefaults
      @$searchTypes[key] = 'number' if angular.isNumber(val)
      @$searchTypes[key] = 'string' if angular.isString(val)
      @$searchTypes[key] = 'boolean' if val == true || val == false
      delete @$searchDefaults[key] if angular.isUndefined(val)

    @scope.$on '$routeUpdate', =>
      last = @$lastSearch = @$search
      @$search = null

      current = @search()
      for [ params, listener ] in @$searchWatchers
        if params[0] == '*' || _.some(params, (param) -> current[param] != last[param])
          listener.call(@, current, last)
      undefined

    @$searchWatchers = []
    @$lastSearch = null

  search: (params) ->
    if arguments.length == 1
      params = angular.copy params

      # delete default values from params
      for key, def of @$searchDefaults
        delete params[key] if params[key] == def

      # normalize non-string values
      for key, val of params
        if angular.isUndefined(val)
          delete params[key]
        else if ! val?
          params[key] = ''
        else if @$searchTypes[key] == 'boolean'
          params[key] = (if val then 'true' else 'false')
        else if ! angular.isString(val)
          params[key] = "#{val}"

      @location.search(params)
    else
      if ! @$search?
        @$search = params = angular.extend({}, @$searchDefaults, @location.search())

        # convert strings values to required types
        for key, type of @$searchTypes
          if angular.isString(val = params[key])
            params[key] =
              switch type
                when 'number' then parseInt(val)
                when 'boolean' then val == 'true'
                else val

      angular.copy @$search
