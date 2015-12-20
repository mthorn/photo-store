@app.factory 'Member', [
  '$resource',
  ($resource) ->
    $resource '/api/libraries/:library_id/members/:id.json'
]
