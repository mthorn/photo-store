@app.component 'modalProfile',

  bindings:
    modalInstance: '<'

  template: """
    <div class='modal-header'>
      <h3 class='modal-title'>Profile</h3>
    </div>
    <div class='modal-body form form-horizontal'>
      <div class='form-group'>
        <label class='control-label col-sm-3' for='email'>Email</label>
        <div class='col-sm-9' errors='$ctrl.errors.email'>
          <input class='form-control' id='email' ng-model='$ctrl.view.email' type='email'>
        </div>
      </div>
      <div class='form-group'>
        <label class='control-label col-sm-3' for='name'>Name</label>
        <div class='col-sm-9' errors='$ctrl.errors.name'>
          <input class='form-control' id='name' ng-model='$ctrl.view.name' type='text'>
        </div>
      </div>
      <div class='form-group' ng-if='$ctrl.Library.mine.length &gt; 1'>
        <label class='control-label col-sm-3' for='default_library_id'>Default Library</label>
        <div class='col-sm-9' errors='$ctrl.errors.default_library_id'>
          <select class='form-control' id='default_library_id' ng-model='$ctrl.view.default_library_id' ng-options='lib.id as lib.name for lib in $ctrl.Library.mine' type='text'></select>
        </div>
      </div>
      <div class='form-group' uib-tooltip='The maximum amount of upload data that will be discarded if an upload is paused or a transient error occurs with the storage provider.'>
        <label class='control-label col-sm-3' for='upload_block_size_mib'>Upload Block Size (MiB)</label>
        <div class='col-sm-9' errors='$ctrl.errors.upload_block_size_mib'>
          <input class='form-control' id='upload_block_size_mib' ng-model='$ctrl.view.upload_block_size_mib' type='number'>
        </div>
      </div>
    </div>
    <div class='modal-footer'>
      <button busy-click='$ctrl.save()' class='btn btn-primary'>Save</button>
      <button class='btn btn-default' ng-click='$ctrl.modalInstance.dismiss()'>Cancel</button>
    </div>
  """

  controller: class extends BaseCtrl
    @inject 'User'

    $onInit: ->
      @user = @User.me
      @view = new @User @user

    save: ->
      @errors = null
      @view.$update().
        then(=> angular.copy(@view, @user)).
        then(=> @modalInstance.close()).
        catch((response) => @errors = response.data)
