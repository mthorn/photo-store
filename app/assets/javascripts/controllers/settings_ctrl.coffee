@app.controller 'SettingsCtrl', class SettingsCtrl extends BaseCtrl

  @inject '$uibModalInstance', '$location', 'Library', 'library'

  initialize: ->
    @library.$get().then =>
      @view = new @Library _.omit(@library, [ 'selection' ])

  save: ->
    @errors = null
    @view.$update().
      then(=> angular.copy(@view, @library)).
      then(=> @uibModalInstance.close()).
      catch((response) => @errors = response.data)
