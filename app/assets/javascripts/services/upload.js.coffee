@app.factory 'Upload', [
  '$resource', '$q', 'fileUpload', 'formData', 'schedule', 'Library',
  ($resource,   $q,   fileUpload,   formData,   schedule,   Library) ->

    Upload = $resource '/api/libraries/:library_id/uploads/:id.json'

    Upload::start = ->
      file = @file
      delete @file

      done = total = 0
      posts = null

      paused = cancel = false
      upload = null
      deferred = $q.defer()

      uploadNextBlock = ->
        if posts.length == 0
          deferred.resolve()
          return
        else if cancel
          deferred.reject('cancel')
        else if paused
          return

        post = posts.shift()
        [ url, postData, offset, length ] = post

        reader = new FileReader
        reader.onload = ->
          block = new Blob [ (new Uint8Array(reader.result, offset, length)) ], type: 'application/octet-stream'

          schedule.retryable(->
            if cancel
              $q.reject 'cancel'
            else if paused
              $q.reject 'paused'
            else
              upload = fileUpload
                url: url
                data: formData().add(postData).build('file', block)
              upload.finally(-> upload = null).then(
                (->
                  done += length
                  uploadNextBlock()
                ),
                null,
                ((event) ->
                  deferred.notify(loaded: done + event.loaded, total: total)
                )
              )
              upload
          ).catch((reason) ->
            posts.unshift(post)
            deferred.reject(reason) if reason != 'paused'
          )

        reader.onerror = ->
          deferred.reject('file read error')

        reader.readAsArrayBuffer(file)
        null

      promise = @$save().
        then(=>
          posts = @file_posts
          for post in posts
            total += post.length
          uploadNextBlock()
          deferred.promise
        ).
        then(=> schedule.retryable => @$update(file_uploaded: true)).
        catch((reason) =>
          @$delete() if @id # delete partially completed upload (eg. provision step succeeds but S3 rejects file)
          $q.reject(if cancel then 'cancel' else reason)
        ).
        then((upload) -> Library.trigger('change', upload))

      promise.abort = ->
        cancel = true
        upload?.abort()
        deferred.reject('cancel')
        null

      promise.pause = ->
        paused = true
        upload?.abort()
        null

      promise.unpause = ->
        paused = false
        uploadNextBlock()

      promise

    Upload
]

