@app.factory 'Upload', [
  '$resource', '$q', 'fileUpload', 'formData', 'config',
  ($resource,   $q,   fileUpload,   formData,   config) ->

    Upload = $resource '/api/uploads/:id.json'

    Upload::create = ->
      file = @file
      delete @file

      doUpload = (options = {}) =>
        fileUpload
          url: options.url || @url()
          # NB: File must be last parameter because S3 ignores everything after it! /facepalm
          data: formData().add(options.data || @).build('file', file)

      upload =
        if config.s3DirectUpload
          @$save().
            then(=> doUpload(url: @file_s3_target, data: @file_s3_post_data)).
            then(=> @$update(file_uploaded: true))
        else
          doUpload().then((data) => angular.extend @, data)

      upload.catch((reason) =>
        @$delete() if @id # delete partially completed upload (eg. provision step succeeds but S3 rejects file)
        $q.reject reason
      )

    Upload
]

