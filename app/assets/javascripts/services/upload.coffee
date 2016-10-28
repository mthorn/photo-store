@app.factory 'Upload', [
  '$resource', '$q', '$uibModal', 'fileUpload', 'formData', 'schedule', 'Library',
  ($resource,   $q,   $uibModal,   fileUpload,   formData,   schedule,   Library) ->

    class Upload extends $resource '/api/libraries/:library_id/uploads/:id.json'

      start: ->
        file = @file
        delete @file

        done = total = 0
        posts = null

        paused = cancel = false
        upload = null
        uploadDeferred = $q.defer()
        fileDataPromise = null

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
          fileDataPromise.then(
            ((fileData) ->
              if fileData
                block = new Blob(
                  [ new Uint8Array(fileData, offset, length) ],
                  type: 'application/octet-stream'
                )
              else
                block = file

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

        promise = @$save().
          then(=>
            posts = @file_posts
            for post in posts
              total += post.length

            if posts.length == 1
              fileDataPromise = $q.when()
            else
              fileDataPromise = $q (resolve, reject) ->
                reader = new FileReader
                reader.onload = -> resolve(reader.result)
                reader.onerror = reject
                reader.readAsArrayBuffer(file)

            uploadNextBlock()
            uploadDeferred.promise
          ).
          then(=> schedule.retryable => @$update(file_uploaded: true)).
          catch((reason) =>
            @$delete() if @id # delete partially completed upload (eg. provision step succeeds but S3 rejects file)
            $q.reject(if cancel then 'cancel' else reason)
          ).
          then((upload) -> Library.trigger('change'))

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

      style: ->
        if @rotate
          transform: "rotate(#{@rotate}deg)"
        else if @rotate?
          {}

      editTags: ->
        $uibModal.open(
          component: 'modalTagsEdit'
          resolve:
            heading: -> "Tags"
            tags: => @tags
            negatives: -> false
            library: => Library.current
        ).result.then((@tags) =>
          @$update()
        ).then(=>
          Library.trigger('change')
        )

      restore: ->
        @deleted_at = null
        @$update().then(=> Library.trigger('change'))

      delete: ->
        (
          if @deleted_at?
            @$delete()
          else
            @deleted_at = new Date
            @$update()
        ).then(=>
          Library.trigger('change')
        )

      applyRotate: (angle) ->
        angle += @rotate
        angle += 360 if angle < 0
        @rotate = angle % 360
        @$update()
]
