class @IndexCtrl extends Controller

  @inject '$http', '$window', '$location', '$routeParams', '$uibModal',
    'Upload', 'Library', 'schedule', 'placeholderImageUrl', 'selection'

  initialize: ->
    @scope.$watch @parseSearchParams, ((@params) =>), true
    @scope.$watch (=> @params), @fetch, true
    @Library.on('change', @fetch)
    @selection.ctrl = @
    @counter = 0

  fetch: =>
    return if @destroyed

    params = _.pick(@params, (v) -> v?)

    if changed = ! angular.equals(params, @parseSearchParams())
      @location.search(params)

    if ! changed && (@fetching || @fetchAgain)
      return @fetchAgain = true

    @timer?.cancel()

    counter = @counter += 1
    @fetching = @query(@queryParams()).then((data) =>
      return unless counter == @counter

      @items = data.items.map((upload) => new @Upload(upload))
      @items.count = data.count

      if @fetchAgain || _.some(@items, state: 'process')
        @timer?.cancel()
        @timer = @schedule.delay(5000, @fetch)
      null
    ).catch(=>
      @timer?.cancel()
      @timer = @schedule.delay(5000, @fetch)
    ).finally(=>
      return unless counter == @counter
      @fetching = null
      @fetchAgain = false
    )

  query: (params) =>
    @http(
      method: 'GET'
      url: "/api/libraries/#{@routeParams.library_id}/uploads.json"
      params: params
    ).then((response) ->
      response.data
    )

  editTags: (upload) ->
    @uibModal.open(
      templateUrl: 'tags_edit.html'
      scope: angular.extend (scope = @scope.$new()),
        heading: "Tags"
        tags: upload.tags
        negatives: false
        library: @Library.current
    ).result.finally(->
      scope.$destroy()
    ).then((tags) ->
      upload.tags = tags
      upload.$update()
    )

  restore: (upload) ->
    upload.deleted_at = null
    upload.$update().then(=> @fetch())

  delete: (upload) ->
    (
      if upload.deleted_at?
        upload.$delete()
      else
        upload.deleted_at = new Date
        upload.$update()
    ).then(=>
      @fetch()
    )

  anyFilters: ->
    @params.tags || @params.filters

  '$on($destroy)': =>
    @destroyed = true
    @counter += 1
    @timer?.cancel()
    @Library.off('change', @fetch)
    delete @selection.ctrl
