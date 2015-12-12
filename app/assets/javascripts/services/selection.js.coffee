@app.factory 'selection', [
  '$rootScope', '$location', '$http', '$route', '$q', '$modal', 'Library', 'User',
  ($rootScope,   $location,   $http,   $route,   $q,   $modal,   Library,   User) ->

    $rootScope.$watch (-> Library.current), (lib) ->
      setIds(lib.selection ||= [])

    $rootScope.$watchCollection (-> service.ids), (ids) ->
      return unless ids?
      lib = Library.current
      return if angular.equals(ids, lib.selection)
      $http(
        method: 'PUT'
        url: lib.url()
        data: { selection: (lib.selection = angular.copy(ids)) }
      )

    setIds = (ids) ->
      service.ids = _.uniq(ids.sort((a, b) -> a - b), true)

    startId = null

    service =
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

        $q.when(@ctrl?.pageIds?()).then (pageIds) =>
          if event.shiftKey && startId? && pageIds? && (i = pageIds.indexOf(startId)) != -1
            j = pageIds.indexOf(uploadId)
            if i < j
              @insert(pageIds.slice(i, j + 1))
            else
              @insert(pageIds.slice(j, i + 1))
          else if (i = @indexOf(uploadId)) != -1
            @ids.splice(i, 1)
          else
            @insert([ uploadId ])
            startId = uploadId

      isSelected: (uploadId) ->
        @enabled && @indexOf(uploadId) != -1

      indexOf: (uploadId) ->
        _.indexOf(@ids, uploadId, true)

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
        $location.url "/#{Library.current.id}/gallery?selected=true"

      deleteSelected: ->
        Library.current.$deleteSelected().then =>
          @ids = []
          if (params = $location.search()).selected == 'true'
            $location.search _.omit(params, 'selected')
          else
            Library.trigger('change')

      editTags: ->
        return if @count() == 0
        $modal.open(
          templateUrl: 'tags_edit.html'
          scope: angular.extend $rootScope.$new(),
            heading: "Add/Remove Tags (#{@count()} items selected)"
            negatives: true
            library: Library.current
        ).result.then((tags) ->
          Library.current.$updateSelected(tags: tags)
        )
]
