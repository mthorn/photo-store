@app.factory 'fileUpload', [
  '$q', '$rootScope', '$http', 'formData',
  ($q,   $rootScope,   $http,   formData) ->

    fileUpload = (options) ->
      deferred = $q.defer()

      $q.when($.ajax
        url: options.url
        type: options.type || 'POST'
        data: formData.build(options.data)
        headers: _.pick($http.defaults.headers.common, [ 'X-CSRF-Token', 'X-Call-Token' ])
        cache: false
        xhr: ->
          fn = (event) ->
            return unless event.lengthComputable
            $rootScope.$apply -> deferred.notify
              loaded: event.loaded
              total: event.total
              percent: event.loaded / event.total * 100
          xhr = $.ajaxSettings.xhr()
          xhr.upload?.addEventListener('progress', fn, false)
          xhr
        xhrFields:
          withCredentials: true
        contentType: false
        processData: false
      ).then(
        deferred.resolve,
        ((xhr) ->
          # transform $.ajax error response to something more like what $http would return
          deferred.reject
            status: xhr.status
            statusText: xhr.statusText
            data: xhr.responseJSON
        )
      )

      deferred.promise

    fileUpload.extendResource = (resourceCls, options) ->
      methodName = "upload#{options.field.camelize()}"

      resourceCls::[methodName] = (fileOrBlob, fileName, params = {}) ->
        fileUpload(
          url: @url()
          type: 'PUT'
          data: formData().add(params).add(options.field, fileOrBlob, fileName).build()
        ).then((data) =>
          angular.extend @, data
        )

      resourceCls[methodName] = (fileOrBlob, fileName, params) ->
        params = angular.copy params

        fileUpload(
          url: (new resourceCls(params)).url()
          data: formData().add(params).add(options.field, fileOrBlob, fileName).build()
        ).then((data) ->
          new resourceCls data
        )

    fileUpload
]
