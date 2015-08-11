@app.controller 'SlidesCtrl', class SlidesCtrl extends IndexCtrl

  initialize: ->
    super
    @idx = parseInt(@location.search().idx) || 0
    @limit = 100
    @offset = Math.floor(@idx / @limit) * @limit

  upload: ->
    @items?[@idx - @offset]

  '$watch(idx)': =>
    @idx = Math.max(@idx, 0)
    @offset = Math.floor(@idx / @limit) * @limit
    @location.search(idx: @idx)
