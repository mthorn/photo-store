@app.controller 'RolesCtrl', class RolesCtrl extends BaseCtrl

  @inject '$q', 'Role', 'library'

  initialize: ->
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
