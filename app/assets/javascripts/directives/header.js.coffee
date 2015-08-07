@app.directive 'header', ->
  templateUrl: 'header.html'
  scope: true
  controller: class extends Controller
    @inject '$location', 'config'

    path: -> @location.path()

  controllerAs: 'ctrl'
