@app.controller 'GalleryCtrl', class GalleryCtrl extends Controller

  @inject 'Upload'

  initialize: ->
    @Upload.query().$promise.then((@uploads) =>)
