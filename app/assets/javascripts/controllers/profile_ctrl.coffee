@app.controller 'ProfileCtrl', class ProfileCtrl extends BaseCtrl

  @inject '$uibModalInstance', 'User', 'Library'

  initialize: ->
    @user = @User.me
    @view = new @User @user

  save: ->
    @errors = null
    @view.$update().
      then(=> angular.copy(@view, @user)).
      then(=> @uibModalInstance.close()).
      catch((response) => @errors = response.data)
