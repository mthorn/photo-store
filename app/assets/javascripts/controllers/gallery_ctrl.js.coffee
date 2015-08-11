@app.controller 'GalleryCtrl', class GalleryCtrl extends IndexCtrl

  initialize: ->
    super
    @offset = parseInt(@location.search().offset) || 0
    @limit = parseInt(@location.search().limit) || 12

  '$watch(offset)': =>
    @fetch('force')
    @location.search(offset: @offset, limit: @limit)
