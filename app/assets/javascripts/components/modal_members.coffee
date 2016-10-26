@app.component 'modalMembers',

  bindings:
    resolve: '<'
    modalInstance: '<'

  template: """
    <div class='modal-header'>
      <h3 class='modal-title'>{{$ctrl.library.name}} Members</h3>
    </div>
    <div class='modal-body'>
      <table class='table'>
        <thead>
          <th>Name</th>
          <th>Email</th>
          <th>Role</th>
        </thead>
        <tbody>
          <tr ng-repeat='member in $ctrl.members | orderBy:"id" track by member.id'>
            <td ng-class='{ "has-error": member.errors.name }'>
              <input class='form-control' ng-change='member.changed = true' ng-disabled='member.me' ng-model='member.name' type='text'>
            </td>
            <td ng-class='{ "has-error": member.errors.email }'>
              <input class='form-control' ng-change='member.changed = true' ng-disabled='member.me' ng-model='member.email' type='email'>
            </td>
            <td>
              <select class='form-control' ng-change='member.changed = true' ng-disabled='member.me' ng-model='member.role_id' ng-options='role.id as role.name for role in $ctrl.roles'></select>
            </td>
            <td>
              <button class='btn btn-default' ng-click='$ctrl.save(member)' ng-disabled='! member.changed' ng-hide='member.me'>
                Save
              </button>
            </td>
            <td>
              <button class='btn btn-default' ng-click='$ctrl.destroy(member)' ng-hide='member.me'>
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
    @inject '$q', 'Member', 'Role', 'User'

    $onInit: ->
      @library = @resolve.library

      @$q.all([
        @Member.query(library_id: @library.id).$promise,
        @Role.query(library_id: @library.id).$promise
      ]).then(([ @members, @roles ]) =>
        _.find(@members, user_id: @User.me.id)?.me = true
      )

    new: ->
      @members.push(new @Member(library_id: @library.id))

    save: (member) ->
      delete member.errors
      (if member.id? then member.$update() else member.$save()).
        catch((response) -> member.errors = response.data)

    destroy: (member) ->
      @$q.when(member.$delete() if member.id?).
        then(=> _.remove(@members, (r) -> r == member))
