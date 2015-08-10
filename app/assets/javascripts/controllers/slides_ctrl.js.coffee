@app.controller 'SlidesCtrl', class SlidesCtrl extends Controller

  @inject '$http', '$window', '$location', 'Upload', 'schedule'

  initialize: ->
    @idx = parseInt(@location.search().idx) || 0
    @limit = 100
    @offset = Math.floor(@idx / @limit) * @limit
    @count = 0

    @Upload.on('uploaded', @fetch)

  fetch: =>
    return @offset = 0 if @offset < 0

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
      @upload = @items?[@idx - @offset]

      @timer?.cancel()
      if _.any(@items, state: 'process')
        @timer = @schedule.delay(5000, @fetch)
    )

  '$watch(idx)': =>
    @idx = Math.max(@idx, 0)
    @upload = @items?[@idx - @offset]
    @offset = Math.floor(@idx / @limit) * @limit
    @location.search(idx: @idx)

  '$watch(offset)': => @fetch()

  '$on($destroy)': =>
    @timer?.cancel()
    @Upload.off('uploaded', @fetch)
