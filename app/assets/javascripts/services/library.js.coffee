@app.factory 'Library', [
  '$resource', '$rootScope', '$routeParams', 'Observable', 'config',
  ($resource,   $rootScope,   $routeParams,   Observable,   config) ->
    Library = $resource '/api/libraries/:id.json', {},
      deleteSelected:
        method: 'DELETE'
        url: '/api/libraries/:id/selected.json'
      restoreDeleted:
        method: 'PUT'
        url: '/api/libraries/:id/deleted.json'
      removeDeleted:
        method: 'DELETE'
        url: '/api/libraries/:id/deleted.json'

    angular.extend Library, Observable

    Library.mine = config.libraries.map((library) -> new Library(library))

    $rootScope.$watch (-> $routeParams.library_id), (id = config.defaultLibraryId) ->
      Library.current = _.findWhere(Library.mine, id: parseInt(id))

    Library
]
