@app.factory 'Role', [
  '$resource',
  ($resource) ->
    $resource '/api/libraries/:library_id/roles/:id.json'
]
