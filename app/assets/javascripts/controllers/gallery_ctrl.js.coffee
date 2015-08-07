@app.controller 'GalleryCtrl', class GalleryCtrl extends Controller

  @inject '$http', '$window', 'Upload', 'schedule', 'config'

  initialize: ->
    @offset = 0
    @limit = 12
    @count = 0

    @Upload.on('uploaded', @fetch)

  fetch: =>
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

  '$on($destroy)': => @Upload.off('uploaded', @fetch)
