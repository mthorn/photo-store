@app.factory 'Upload', [
  '$resource', '$q', 'fileUpload', 'formData', 'Observable',
  ($resource,   $q,   fileUpload,   formData,   Observable) ->

    Upload = $resource '/api/uploads/:id.json'

    angular.extend Upload, Observable

    Upload::create = ->
      file = @file
      delete @file

      @$save().
        then(=> fileUpload(url: @file_post_url, data: formData().add(@file_post_data).build('file', file))).
        then(=> @$update(file_uploaded: true)).
        catch((reason) =>
          @$delete() if @id # delete partially completed upload (eg. provision step succeeds but S3 rejects file)
          $q.reject reason
        ).
        then((upload) -> Upload.trigger('uploaded', upload))

    Upload
]

