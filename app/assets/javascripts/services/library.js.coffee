@app.factory 'Library', [
  '$resource', '$rootScope', '$routeParams', 'config',
  ($resource,   $rootScope,   $routeParams,   config) ->
    Library = $resource '/api/libraries/:id.json'
    Library.mine = config.libraries.map((library) -> new Library(library))

    $rootScope.$watch (-> $routeParams.library_id), (id = config.defaultLibraryId) ->
      Library.current = _.findWhere(Library.mine, id: parseInt(id))

    Library
]
