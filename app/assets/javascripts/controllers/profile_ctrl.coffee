@app.controller 'ProfileCtrl', class ProfileCtrl extends BaseCtrl

  @inject '$modalInstance', 'User', 'Library'

  initialize: ->
    @user = @User.me
    @view = new @User @user

  save: ->
    @errors = null
    @view.$update().
      then(=> angular.copy(@view, @user)).
      then(=> @modalInstance.close()).
      catch((response) => @errors = response.data)
