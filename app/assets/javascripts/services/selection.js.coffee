@app.factory 'selection', [
  '$rootScope', '$location', '$http', '$route', 'Library', 'User',
  ($rootScope,   $location,   $http,   $route,   Library,   User) ->

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

    service =
      manualDeselect: (setting) ->
        if setting == 'toggle'
          User.me.$update(manual_deselect: ! User.me.manual_deselect)
        else if setting?
          User.me.$update manual_deselect: setting
        else
          User.me.manual_deselect

      click: (event, uploadId) ->
        @clear() unless User.me.manual_deselect || event.ctrlKey || event.metaKey

        if (i = @indexOf(uploadId)) != -1
          @ids.splice(i, 1)
        else
          @insert([ uploadId ])

      isSelected: (uploadId) ->
        @indexOf(uploadId) != -1

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
]
