@app.factory 'Upload', [
  '$resource', '$q', 'fileUpload', 'formData', 'schedule', 'Observable',
  ($resource,   $q,   fileUpload,   formData,   schedule,   Observable) ->

    Upload = $resource '/api/libraries/:library_id/uploads/:id.json'

    angular.extend Upload, Observable

    Upload::create = ->
      file = @file
      delete @file

      cancel = false
      upload = null

      promise = @$save().
        then(=>
          schedule.retryable =>
            if cancel
              $q.reject 'cancel'
            else
              upload = fileUpload
                url: @file_post_url
                data: formData().add(@file_post_data).build('file', file)
        ).
        finally(-> upload = null).
        then(=> schedule.retryable => @$update(file_uploaded: true)).
        catch((reason) =>
          @$delete() if @id # delete partially completed upload (eg. provision step succeeds but S3 rejects file)
          $q.reject(if cancel then 'cancel' else reason)
        ).
        then((upload) -> Upload.trigger('uploaded', upload))

      promise.abort = ->
        upload?.abort()
        cancel = true
        null

      promise

    Upload
]

