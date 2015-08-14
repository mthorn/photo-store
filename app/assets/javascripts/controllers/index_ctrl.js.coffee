class @IndexCtrl extends Controller

  @inject '$http', '$window', '$location', '$routeParams', 'Upload',
    'schedule', 'placeholderImageUrl'

  initialize: ->
    @count = 0
    @order = @location.search().order || ''

    @Upload.on('uploaded', @fetch)

  fetch: =>
    params = @queryParams()
    if changed = ! angular.equals(@location.search(), params)
      @location.search(params)

    if ! changed && (@fetching || @fetchAgain)
      return @fetchAgain = true

    @timer?.cancel()
    @fetching = @http(
      method: 'GET'
      url: "/api/libraries/#{@routeParams.library_id}/uploads.json"
      params:
        offset: @offset
        limit: @limit
        order: @order
    ).then((response) =>
      @items = response.data.items.map((upload) => new @Upload(upload))
      @items.count = response.data.count

      @fetching = null
      if @fetchAgain || _.any(@items, state: 'process')
        @fetchAgain = false
        @timer?.cancel()
        @timer = @schedule.delay(5000, @fetch)
    )

  '$watch(order)': (order, oldOrder) =>
    @fetch() if oldOrder

  '$on($destroy)': =>
    @timer?.cancel()
    @Upload.off('uploaded', @fetch)
