@app.controller 'SlidesCtrl', class SlidesCtrl extends IndexCtrl

  initialize: ->
    super
    @idx = parseInt(@location.search().idx) || 0
    @idx = 0 if @idx < 0
    @limit = 100
    @offset = Math.floor(@idx / @limit) * @limit

  upload: ->
    @items?[@idx - @offset]

  queryParams: ->
    idx: @idx

  '$watch(idx)': =>
    @offset = Math.floor(@idx / @limit) * @limit
    @fetch()
