@app.component 'modalRoles',

  bindings:
    resolve: '<'
    modalInstance: '<'

  template: """
    <div class='modal-header'>
      <h3 class='modal-title'>{{$ctrl.library.name}} Roles</h3>
    </div>
    <div class='modal-body'>
      <table class='table'>
        <thead>
          <th>Name</th>
          <th>Upload?</th>
          <th>Restrict Tags</th>
        </thead>
        <tbody>
          <tr ng-repeat='role in $ctrl.roles | orderBy:"id" track by role.id'>
            <td ng-class='{ "has-error": role.errors.name }'>
              <input class='form-control' ng-change='role.changed = true' ng-disabled='role.owner' ng-model='role.name' type='text'>
            </td>
            <td>
              <input ng-change='role.changed = true' ng-disabled='role.owner' ng-model='role.can_upload' type='checkbox'>
            </td>
            <td>
              <tags-input add-on-space='true' allowed-tags-pattern='^-?[a-z0-9][a-z0-9&amp;-]*$' min-length='2' ng-if='! role.owner' ng-model='$restrict_tags' on-tag-added='role.changed = true' on-tag-removed='role.changed = true' tags-model-type='array' tags-model='role.restrict_tags' template='tag.html'>
                <auto-complete debounce-delay='0' load-on-down-arrow='true' load-on-empty='true' min-length='1' source='$ctrl.library.suggestTags($query)' template='tag_suggestion.html'></auto-complete>
              </tags-input>
            </td>
            <td>
              <button class='btn btn-default' ng-click='$ctrl.save(role)' ng-disabled='! role.changed' ng-hide='role.owner'>
                Save
              </button>
            </td>
            <td>
              <button class='btn btn-default' ng-click='$ctrl.destroy(role)' ng-hide='role.owner'>
                Remove
              </button>
            </td>
          </tr>
          <tr>
            <td>
              <button class='btn btn-default' ng-click='$ctrl.new()'>New</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class='modal-footer'>
      <button class='btn btn-default' ng-click='$ctrl.modalInstance.close()'>Close</button>
    </div>
  """

  controller: class extends BaseCtrl
    @inject '$q', 'Role'

    $onInit: ->
      @library = @resolve.library
      @roles = @Role.query(library_id: @library.id)

    new: ->
      @roles.push(new @Role(library_id: @library.id))

    save: (role) ->
      delete role.errors
      (if role.id? then role.$update() else role.$save()).
        catch((response) -> role.errors = response.data)

    destroy: (role) ->
      @$q.when(role.$delete() if role.id?).
        then(=> _.remove(@roles, (r) -> r == role))
