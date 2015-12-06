@app.controller 'SlidesCtrl', class SlidesCtrl extends IndexCtrl
  @inject 'imageCache'

  LIMIT = 100
  CACHE_AHEAD = 5

  initialize: ->
    super
    @scope.$watch (=> @upload()), @updateCache

  parseSearchParams: =>
    r = angular.extend({ i: 0 }, @location.search())
    r.i = Math.max(0, parseInt(r.i))
    r

  queryParams: ->
    angular.extend _.pick(@params, 'order', 'tags', 'filters'),
      limit: LIMIT
      offset: @getOffset()

  upload: ->
    @items?[@params.i - @getOffset()]

  getOffset: ->
    Math.floor(@params.i / LIMIT) * LIMIT

  updateCache: =>
    return unless @items?

    i = @params.i
    offset = @getOffset()
    for j in _.range(i, Math.min(i + CACHE_AHEAD, LIMIT))
      if (upload = @items[j])?
        @imageCache.store(upload.large_url)
