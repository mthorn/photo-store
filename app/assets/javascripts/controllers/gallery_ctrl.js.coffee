@app.controller 'GalleryCtrl', class GalleryCtrl extends IndexCtrl

  initialize: ->
    super
    @limitOptions = [ 12, 24, 48, 96 ].map((i) -> { i: i })
    @page = parseInt(@location.search().page) || 1
    @page = 1 if @page <= 0
    @limit = parseInt(@location.search().limit) || 24
    @limit = 24 unless @limit in [ 12, 24, 48, 96 ]

    @scope.$watch((=> [ @page, @limit ]), @update, true)

  queryParams: ->
    page: @page
    limit: @limit
    order: @order

  update: ([ page, limit ], [ oldPage, oldLimit ]) =>
    @page = 1 if oldLimit? && limit != oldLimit
    oldOffset = @offset
    @offset = (@page - 1) * @limit
    @fetch()
