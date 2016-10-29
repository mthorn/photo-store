@app.factory 'selection', [
  '$rootScope', '$location', '$http', '$route', '$q', '$uibModal', 'Library', 'User', 'SearchObserver',
  ($rootScope,   $location,   $http,   $route,   $q,   $uibModal,   Library,   User,   SearchObserver) ->

    service = {}

    SearchObserver($rootScope, select: false).
      bindTo(service).
      bindParam('select', to: 'enabled', onUpdate: 'replace')

    $rootScope.$watch((-> Library.current), (lib) ->
      setIds(lib.selection ||= [])
    )

    $rootScope.$watchCollection((-> service.ids), (ids) ->
      return unless ids?
      lib = Library.current
      return if angular.equals(ids, lib.selection)
      $http(
        method: 'PUT'
        url: lib.url()
        data: { selection: (lib.selection = angular.copy(ids)) }
      )
    )

    setIds = (ids) ->
      service.ids = _.sortedUniq(ids.sort((a, b) -> a - b), true)

    startId = null

    angular.extend service,

      manualDeselect: (setting) ->
        if setting == 'toggle'
          User.me.$update(manual_deselect: ! User.me.manual_deselect)
        else if setting?
          User.me.$update manual_deselect: setting
        else
          User.me.manual_deselect

      click: (event, uploadId) ->
        return unless @enabled

        @clear() unless User.me.manual_deselect || event.ctrlKey || event.metaKey

        if event.shiftKey && startId? && angular.isFunction(@ctrl?.idsBetween)
          @ctrl.idsBetween(startId, uploadId).then((ids) => @insert(ids))
          startId = uploadId
        else if (i = @indexOf(uploadId)) != -1
          @ids.splice(i, 1)
          startId = null
        else
          @insert([ uploadId ])
          startId = uploadId

      isSelected: (uploadId) ->
        @enabled && @indexOf(uploadId) != -1

      indexOf: (uploadId) ->
        _.sortedIndexOf(@ids, uploadId)

      insert: (ids) ->
        setIds(@ids.concat(ids))

      clear: ->
        @ids = []

      isEmpty: ->
        @ids.length == 0

      count: ->
        @ids.length

      isPageAvailable: ->
        @ctrl?.pageIds?

      isAllPagesAvailable: ->
        @ctrl?.allPageIds?

      togglePage: (selected) ->
        @ctrl.pageIds().then (ids) =>
          if selected
            if @manualDeselect()
              setIds(@ids.concat(ids))
            else
              setIds(ids)
          else
            setIds(_.difference(@ids, ids))

      toggleAllPages: (selected) ->
        @ctrl.allPageIds().then (ids) =>
          if selected
            if @manualDeselect()
              setIds(@ids.concat(ids))
            else
              setIds(ids)
          else
            setIds(_.difference(@ids, ids))

      review: ->
        $location.
          path("/#{Library.current.id}/gallery").
          search(angular.extend(_.omit($location.search(), 'deleted', 'tags', 'filters'), selected: 't'))

      deleteSelected: ->
        Library.current.$deleteSelected().then =>
          @ids = []
          if (params = $location.search()).selected == 't'
            $location.search _.omit(params, 'selected')
          else
            Library.trigger('change')

      editTags: ->
        return if @count() == 0
        $uibModal.open(
          component: 'modalTagsEdit'
          resolve:
            heading: => "Add/Remove Tags (#{@count()} items selected)"
            negatives: -> true
            library: -> Library.current
        ).result.then((tags) ->
          Library.current.$updateSelected(tags: tags)
        ).then(->
          Library.trigger('change')
        )
]
