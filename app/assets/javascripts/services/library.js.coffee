@app.factory 'Library', [
  '$resource', '$rootScope', '$routeParams', 'config',
  ($resource,   $rootScope,   $routeParams,   config) ->
    Library = $resource '/api/user.json'
    Library.mine = config.libraries.map((library) -> new Library(library))

    $rootScope.$watch (-> $routeParams.library_id), (id = config.defaultLibraryId) ->
      Library.current = _.findWhere(Library.mine, id: parseInt(id))

    Library
]

