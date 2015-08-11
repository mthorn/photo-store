@app.factory 'Upload', [
  '$resource', '$q', 'fileUpload', 'formData', 'Observable',
  ($resource,   $q,   fileUpload,   formData,   Observable) ->

    Upload = $resource '/api/uploads/:id.json'

    angular.extend Upload, Observable

    Upload::create = ->
      file = @file
      delete @file

      upload = null

      promise = @$save().
        then(=>
          if upload == 'cancel'
            $q.reject 'cancel'
          else
            upload = fileUpload(
              url: @file_post_url
              data: formData().add(@file_post_data).build('file', file)
            )
        ).
        finally(-> upload = null).
        then(=> @$update(file_uploaded: true)).
        catch((reason) =>
          @$delete() if @id # delete partially completed upload (eg. provision step succeeds but S3 rejects file)
          $q.reject reason
        ).
        then((upload) -> Upload.trigger('uploaded', upload))

      promise.abort = ->
        upload?.abort()
        upload = 'cancel'
        null

      promise

    Upload
]

