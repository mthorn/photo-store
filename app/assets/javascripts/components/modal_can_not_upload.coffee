@app.component 'modalCanNotUpload',

  bindings:
    modalInstance: '<'

  template: """
    <div class='modal-header'>
      <h3 class='modal-title'>Access Denied</h3>
    </div>
    <div class='modal-body'>
      <p>
        You are not allowed to upload files to the current library.
      </p>
    </div>
    <div class='modal-footer'>
      <button class='btn btn-primary' ng-click='$ctrl.modalInstance.close()'>Close</button>
    </div>
  """

  controller: class extends BaseCtrl
    $onInit: ->
