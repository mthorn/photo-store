@app.controller 'GalleryCtrl', class GalleryCtrl extends Controller

  @inject '$http', '$window', '$location', 'Upload', 'schedule',
    'placeholderImageUrl'

  initialize: ->
    @offset = parseInt(@location.search().offset) || 0
    @limit = parseInt(@location.search().limit) || 12
    @count = 0

    @Upload.on('uploaded', @fetch)

  fetch: =>
    return @offset = 0 if @offset < 0

    @location.search(offset: @offset, limit: @limit)

    @timer?.cancel()
    @http(
      method: 'GET'
      url: '/api/uploads.json'
      params:
        offset: @offset
        limit: @limit
    ).then((response) =>
      @items = response.data.items.map((upload) => new @Upload(upload))
      @items.count = response.data.count

      @timer?.cancel()
      if _.any(@items, state: 'process')
        @timer = @schedule.delay(5000, @fetch)
    )

  '$watch(offset)': => @fetch()

  '$on($destroy)': =>
    @timer?.cancel()
    @Upload.off('uploaded', @fetch)
