@app.controller 'SlidesCtrl', class SlidesCtrl extends IndexCtrl
  @inject 'imageCache'

  LIMIT = 100
  CACHE_AHEAD = 5
  SEARCH_PARAMS = [ 'i', 'order', 'tags', 'filters' ]

  initialize: ->
    super
    @scope.$watch (=> @upload()), (upload) =>
      @scope.upload = upload
      @updateCache()

    @initSearch({
      i: 0
      order: ''
      tags: ''
      filters: '[]'
    })

  queryParams: ->
    angular.extend _.pick(@params, 'order', 'tags', 'filters'),
      limit: LIMIT
      offset: @getOffset()

  upload: ->
    @items?[@params.i - @getOffset()]

  getOffset: (i = @params.i) ->
    Math.floor(i / LIMIT) * LIMIT

  updateCache: =>
    return unless @items?

    i = @params.i - @getOffset()
    for j in _.range(0, CACHE_AHEAD)
      if (upload = @items[i + j])?
        @imageCache.store(upload.large_url) if upload.type == 'Photo'
      if (upload = @items[i - j])?
        @imageCache.store(upload.large_url) if upload.type == 'Photo'

  change: (delta) ->
    @params.i = Math.min(Math.max(@params.i + delta, 0), @items.count - 1)

  '$watchChange(params)': (params, oldParams) ->
    if params.i == oldParams.i && params.i != 0
      @params.i = 0
    else
      @search(@params)

  '$searchChange(i)': (search, oldSearch) ->
    @params = _.pick(search, SEARCH_PARAMS)
    @fetch() if @getOffset(search.i) != @getOffset(oldSearch.i)

  '$searchChange(order, tags, filters)': (search) ->
    @params = _.pick(search, SEARCH_PARAMS)
    @fetch()
