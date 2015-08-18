@app.controller 'SettingsCtrl', class SettingsCtrl extends Controller

  @inject '$modalInstance', '$location', 'Library', 'library'

  initialize: ->
    @library.$get().then => @view = new @Library @library

  save: ->
    @errors = null
    @view.$update().
      then(=> angular.copy(@view, @library)).
      then(=> @modalInstance.close()).
      catch((response) => @errors = response.data)
