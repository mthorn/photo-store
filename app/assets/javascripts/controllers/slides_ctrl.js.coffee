@app.controller 'SlidesCtrl', class SlidesCtrl extends IndexCtrl

  LIMIT = 100

  parseSearchParams: =>
    r = angular.extend({ i: 0 }, @location.search())
    r.i = Math.max(0, parseInt(r.i))
    r

  queryParams: ->
    angular.extend _.pick(@params, 'order', 'tags', 'filters'),
      limit: LIMIT
      offset: @getOffset()

  upload: ->
    @items?[@params.i - @getOffset()]

  getOffset: ->
    Math.floor(@params.i / LIMIT) * LIMIT
