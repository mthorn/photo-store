@app.factory 'fileUpload', [
  '$q', '$rootScope', '$http', 'formData',
  ($q,   $rootScope,   $http,   formData) ->

    (options) ->
      deferred = $q.defer()
      timeout = $q.defer()

      options.method ?= options.type ? 'POST'
      options.data = formData.build(options.data)
      options.headers ?= {}
      options.headers['Content-Type'] = undefined # browser auto-fills with correct type and boundary
      options.withCredentials = true
      options.uploadEventHandlers =
        progress: (e) ->
          deferred.notify(loaded: e.loaded, total: e.total) if e.lengthComputable
      options.timeout = timeout.promise

      $http(options).then(
        ((response) -> deferred.resolve(response.data)),
        deferred.reject,
        deferred.notify)

      deferred.promise.abort = timeout.resolve
      deferred.promise
]
