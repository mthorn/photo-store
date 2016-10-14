@app.factory 'Library', [
  '$resource', '$rootScope', '$routeParams', 'Observable', 'config',
  ($resource,   $rootScope,   $routeParams,   Observable,   config) ->
    Library = $resource '/api/libraries/:id.json', {},
      deleteSelected:
        method: 'DELETE'
        url: '/api/libraries/:id/selected.json'
      updateSelected:
        method: 'PUT'
        url: '/api/libraries/:id/selected.json'
      restoreDeleted:
        method: 'PUT'
        url: '/api/libraries/:id/deleted.json'
      removeDeleted:
        method: 'DELETE'
        url: '/api/libraries/:id/deleted.json'
      adminIndex:
        method: 'GET'
        url: '/api/admin/libraries.json'
        isArray: true
      adminCreate:
        method: 'POST'
        url: '/api/admin/libraries.json'

    angular.extend Library, Observable

    Library.mine = config.libraries.map((library) -> new Library(library))

    $rootScope.$watch (-> $routeParams.library_id), (id = config.user.default_library_id) ->
      Library.current = _.find(Library.mine, id: parseInt(id))

    Library::suggestTags = (query) ->
      if negative = query[0] == '-'
        query = query.slice(1)
      Object.keys(@tag_counts).
        filter((tag) -> tag.slice(0, query.length) == query).
        sort((a, b) -> if a < b then -1 else if a > b then 1 else 0).
        map((tag) -> if negative then "-#{tag}" else tag)

    Library
]
