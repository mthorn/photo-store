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
      uploadDeferred = $q.defer()
      fileDataDeferred = $q.defer()

      uploadNextBlock = ->
        if posts.length == 0
          uploadDeferred.resolve()
          return
        else if cancel
          uploadDeferred.reject('cancel')
        else if paused
          return

        post = posts.shift()
        [ url, postData, offset, length ] = post
        fileDataDeferred.promise.then(
          ((fileData) ->
            data = new Uint8Array(fileData, offset, length)
            block = new Blob([ data ], type: 'application/octet-stream')

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
                    uploadDeferred.notify(loaded: done + event.loaded, total: total)
                    event
                  )
                )
            ).catch((reason) ->
              posts.unshift(post)
              uploadDeferred.reject(reason) if reason != 'paused'
            )
          ),
          uploadDeferred.reject
        )

        null

      reader = new FileReader
      reader.onload = -> fileDataDeferred.resolve(reader.result)
      reader.onerror = fileDataDeferred.reject
      reader.readAsArrayBuffer(file)

      promise = @$save().
        then(=>
          posts = @file_posts
          for post in posts
            total += post.length
          uploadNextBlock()
          uploadDeferred.promise
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
        uploadDeferred.reject('cancel')
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

