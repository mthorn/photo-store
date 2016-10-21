class @IndexCtrl extends BaseCtrl
  @inject '$http', '$routeParams', '$uibModal', 'Upload', 'Library',
    'schedule', 'placeholderImageUrl', 'selection'

  initialize: ->
    @Library.on('change', @fetch)
    @selection.ctrl = @

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
    ).then(=>
      @Library.trigger('change')
    )

  restore: (upload) ->
    upload.deleted_at = null
    upload.$update().then(=> @Library.trigger('change'))

  delete: (upload) ->
    (
      if upload.deleted_at?
        upload.$delete()
      else
        upload.deleted_at = new Date
        upload.$update()
    ).then(=>
      @Library.trigger('change')
    )

  anyFilters: ->
    @params.tags || @params.filters

  '$on($destroy)': =>
    @destroyed = true
    @timer?.cancel()
    @Library.off('change', @fetch)
    delete @selection.ctrl
