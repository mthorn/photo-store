@app.controller 'MembersCtrl', class MembersCtrl extends BaseCtrl

  @inject '$q', 'Member', 'Role', 'User', 'library'

  initialize: ->
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
