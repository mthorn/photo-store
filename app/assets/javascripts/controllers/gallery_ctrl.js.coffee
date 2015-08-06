@app.controller 'GalleryCtrl', class GalleryCtrl extends Controller

  @inject '$http', '$window', 'Upload'

  initialize: ->
    @offset = 0
    @limit = 12
    @count = 0

  '$watch(offset)': =>
    @http(
      method: 'GET'
      url: '/api/uploads.json'
      params:
        offset: @offset
        limit: @limit
    ).then((response) =>
      @items = response.data.items.map((upload) => new @Upload(upload))
      @items.count = response.data.count
    )
