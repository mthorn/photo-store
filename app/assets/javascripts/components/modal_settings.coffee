@app.component 'modalSettings',

  bindings:
    resolve: '<'
    modalInstance: '<'

  template: """
    <div class='modal-header'>
      <h3 class='modal-title'>{{$ctrl.library.name}}</h3>
    </div>
    <div class='modal-body form form-horizontal'>
      <div class='form-group'>
        <label class='control-label col-sm-3' for='name'>Name</label>
        <div class='col-sm-9' errors='$ctrl.errors.name'>
          <input class='form-control' id='name' ng-model='$ctrl.view.name' type='text'>
        </div>
      </div>
      <div class='form-group'>
        <label class='control-label col-sm-3'>New Upload Tags</label>
        <div class='col-sm-9' errors='$ctrl.errors.tag_new'>
          <tags-input add-on-space='true' allowed-tags-pattern='^[a-z0-9][a-z0-9&amp;-]*$' min-length='2' ng-model='$ctrl.tag_new' placeholder='Tags' tags-model='$ctrl.view.tag_new' template='tag.html'></tags-input>
        </div>
      </div>
      <div class='form-group'>
        <div class='col-sm-9 col-sm-offset-3'>
          <div class='checkbox'>
            <label>
              <input ng-model='$ctrl.view.tag_aspect' type='checkbox'>
              Tag Orientation
            </label>
          </div>
        </div>
      </div>
      <div class='form-group'>
        <div class='col-sm-9 col-sm-offset-3'>
          <div class='checkbox'>
            <label>
              <input ng-model='$ctrl.view.tag_date' type='checkbox'>
              Tag Month &amp; Year
            </label>
          </div>
        </div>
      </div>
      <div class='form-group'>
        <div class='col-sm-9 col-sm-offset-3'>
          <div class='checkbox'>
            <label>
              <input ng-model='$ctrl.view.tag_camera' type='checkbox'>
              Tag Camera
            </label>
          </div>
        </div>
      </div>
      <div class='form-group'>
        <div class='col-sm-9 col-sm-offset-3'>
          <div class='checkbox'>
            <label>
              <input ng-model='$ctrl.view.tag_location' type='checkbox'>
              Tag Location
            </label>
          </div>
        </div>
      </div>
    </div>
    <div class='modal-footer'>
      <button busy-click='$ctrl.save()' class='btn btn-primary'>Save</button>
      <button class='btn btn-default' ng-click='$ctrl.modalInstance.dismiss()'>Cancel</button>
    </div>
  """

  controller: class extends BaseCtrl
    @inject '$location', 'Library'

    $onInit: ->
      @library = @resolve.library
      @library.$get().then =>
        @view = new @Library _.omit(@library, [ 'selection' ])

    save: ->
      @errors = null
      @view.$update().
        then(=> angular.copy(@view, @library)).
        then(=> @modalInstance.close()).
        catch((response) => @errors = response.data)
