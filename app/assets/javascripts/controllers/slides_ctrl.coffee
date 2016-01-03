@app.controller 'SlidesCtrl', class SlidesCtrl extends IndexCtrl
  @inject 'imageCache'

  LIMIT = 100
  CACHE_AHEAD = 5

  initialize: ->
    super
    @scope.$watch (=> @upload()), (upload) =>
      @scope.upload = upload
      @updateCache()

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

    i = @params.i - @getOffset()
    for j in _.range(0, CACHE_AHEAD)
      if (upload = @items[i + j])?
        @imageCache.store(upload.large_url) if upload.type == 'Photo'
      if (upload = @items[i - j])?
        @imageCache.store(upload.large_url) if upload.type == 'Photo'
