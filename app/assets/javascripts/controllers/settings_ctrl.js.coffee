@app.controller 'SettingsCtrl', class SettingsCtrl extends Controller

  @inject '$routeParams', 'Library'

  initialize: ->
    @library = _.findWhere(@Library.mine, id: parseInt(@routeParams.library_id))
    @library.$get().then =>
      @view = new @Library @library

  update: ->
    @errors = null
    @view.$update().
      then(=> angular.copy(@view, @library)).
      catch((response) => @errors = response.data)
