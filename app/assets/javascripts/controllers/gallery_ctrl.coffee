@app.controller 'GalleryCtrl', class GalleryCtrl extends IndexCtrl

  LIMIT_OPTIONS = [ 12, 24, 48, 96 ]

  @inject '$q'

  initialize: ->
    super
    @limitOptions = LIMIT_OPTIONS.map((i) -> { value: i, label: "#{i}" })

    @initSearch({
      page: 1
      limit: 48
      order: ''
      selected: false
      deleted: false
      tags: ''
      filters: '[]'
    })

  queryParams: ->
    search = @search()
    angular.extend _.pick(search, 'limit', 'order', 'selected', 'deleted', 'tags', 'filters'),
      offset: (search.page - 1) * search.limit

  pageIds: ->
    @q.when(@items.map((item) -> item.id))

  allPageIds: ->
    @query angular.extend _.omit(@queryParams(), [ 'offset', 'limit' ]),
      order: 'id-asc'
      only_id: true

  click: (event, upload) ->
    @selection.click(event, upload.id)

  dblclick: (event, upload) ->
    @uibModal.open(
      templateUrl: 'upload_lightbox.html'
      scope: angular.extend(scope = @scope.$new(), upload: upload)
    ).result.finally(->
      scope.$destroy()
    )

  '$searchChange(*)': ->
    @params = _.pick(@search(), 'page', 'limit', 'order', 'selected', 'deleted', 'tags', 'filters')
    @fetch()
