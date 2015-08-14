@app.controller 'SlidesCtrl', class SlidesCtrl extends IndexCtrl

  LIMIT = 100

  parseSearchParams: =>
    i: parseInt(@location.search().i || 0)

  queryParams: ->
    limit: LIMIT
    offset: @getOffset()

  upload: ->
    @items?[@params.i - @getOffset()]

  getOffset: ->
    Math.floor(@params.i / LIMIT) * LIMIT
