class @IndexCtrl extends Controller

  @inject '$http', '$window', '$location', 'Upload', 'schedule',
    'placeholderImageUrl'

  initialize: ->
    @count = 0

    @Upload.on('uploaded', @fetch)

  fetch: (force) =>
    return @offset = 0 if @offset < 0

    if force != 'force' && (@fetching || @fetchAgain)
      return @fetchAgain = true

    @timer?.cancel()
    @fetching = @http(
      method: 'GET'
      url: '/api/uploads.json'
      params:
        offset: @offset
        limit: @limit
    ).then((response) =>
      @items = response.data.items.map((upload) => new @Upload(upload))
      @items.count = response.data.count

      @fetching = null
      if @fetchAgain || _.any(@items, state: 'process')
        @fetchAgain = false
        @timer?.cancel()
        @timer = @schedule.delay(5000, @fetch)
    )

  '$watch(offset)': => @fetch('force')

  '$on($destroy)': =>
    @timer?.cancel()
    @Upload.off('uploaded', @fetch)
