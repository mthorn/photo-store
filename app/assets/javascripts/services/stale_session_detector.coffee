@app.factory 'staleSessionDetector', [
  '$q', '$window',
  ($q,   $window) ->
    responseError: (response) ->
      if response.status == 401
        $window.location.reload()
      else
        $q.reject(response)
]
