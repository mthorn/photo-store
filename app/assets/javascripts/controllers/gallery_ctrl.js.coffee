@app.controller 'GalleryCtrl', class GalleryCtrl extends IndexCtrl

  DEFAULT_PARAMS = { page: 1, limit: 24, order: '' }
  LIMIT_OPTIONS = [ 12, 24, 48, 96 ]

  @inject '$q', '$modal'

  initialize: ->
    super
    @limitOptions = LIMIT_OPTIONS.map((i) -> { i: i })

  parseSearchParams: =>
    r = angular.extend({}, DEFAULT_PARAMS, @location.search())
    for attr in [ 'page', 'limit' ]
      r[attr] = parseInt(r[attr])
    r.page = 1 if r.page <= 0
    r.limit = 24 unless r.limit in LIMIT_OPTIONS
    r

  queryParams: ->
    angular.extend _.pick(@params, 'limit', 'order', 'selected', 'deleted', 'tags', 'filters'),
      offset: (@params.page - 1) * @params.limit

  pageIds: ->
    @q.when(@items.map((item) -> item.id))

  allPageIds: ->
    query = angular.extend _.omit(@queryParams(), [ 'offset', 'limit' ]),
      order: 'id-asc'
      only_id: true
    @query(query).then((data) -> data.items)

  click: (event, upload) ->
    @selection.click(event, upload.id)

  dblclick: (event, upload) ->
    @modal.open(
      templateUrl: 'upload_lightbox.html'
      scope: angular.extend(@scope.$new(), upload: upload)
    )

  editTags: (upload) ->
    @modal.open(
      templateUrl: 'tags_edit.html'
      scope: angular.extend @scope.$new(),
        heading: "Tags"
        tags: upload.tags.map((tag) -> text: tag)
        negatives: false
    ).result.then((tags) ->
      upload.tags = _.map(tags, 'text')
      upload.$update()
    )
