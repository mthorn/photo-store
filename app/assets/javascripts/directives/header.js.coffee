@app.directive 'header', ->
  templateUrl: 'header.html'
  scope: true
  controller: class extends Controller
    @inject '$location', 'Library', 'config'

    library: -> @Library.current
    libraryId: -> @library()?.id
    path: -> @location.path()

  controllerAs: 'ctrl'
