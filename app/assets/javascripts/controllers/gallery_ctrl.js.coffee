@app.controller 'GalleryCtrl', class GalleryCtrl extends IndexCtrl

  DEFAULT_PARAMS = { page: 1, limit: 24, order: '' }
  LIMIT_OPTIONS = [ 12, 24, 48, 96 ]

  initialize: ->
    super
    @limitOptions = LIMIT_OPTIONS.map((i) -> { i: i })

  parseSearchParams: =>
    r = angular.extend({}, DEFAULT_PARAMS, @location.search())
    for attr in [ 'page', 'limit' ]
      r[attr] = parseInt(r[attr])
    r.page = 1 if r.page <= 0
    r.limit = 24 unless r.limit in LIMIT_OPTIONS
    r

  queryParams: ->
    angular.extend _.pick(@params, 'limit', 'order'),
      offset: (@params.page - 1) * @params.limit
