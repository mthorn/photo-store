@app.component 'modalPassword',

  bindings:
    modalInstance: '<'

  template: """
    <div class='modal-header'>
      <h3 class='modal-title'>Change Password</h3>
    </div>
    <div class='modal-body form form-horizontal'>
      <div class='form-group'>
        <label class='control-label col-sm-3' for='password'>Password</label>
        <div class='col-sm-9' errors='$ctrl.errors.password'>
          <input class='form-control' id='password' ng-model='$ctrl.view.password' type='password'>
        </div>
      </div>
      <div class='form-group'>
        <label class='control-label col-sm-3' for='password_confirmation'>Confirm Password</label>
        <div class='col-sm-9' errors='$ctrl.errors.password_confirmation'>
          <input class='form-control' id='password_confirmation' ng-model='$ctrl.view.password_confirmation' type='password'>
        </div>
      </div>
    </div>
    <div class='modal-footer'>
      <button busy-click='$ctrl.save()' class='btn btn-primary'>Save</button>
      <button class='btn btn-default' ng-click='$ctrl.modalInstance.dismiss()'>Cancel</button>
    </div>
  """

  controller: class extends BaseCtrl
    @inject '$http', '$window'

    $onInit: ->
      @view = password: '', password_confirmation: ''

    save: ->
      @errors = null
      @http(
        method: 'PUT'
        url: '/api/user.json'
        data: @view
      ).then(=>
        @window.location.reload()
      ).catch((response) =>
        @errors = response.data
      )
