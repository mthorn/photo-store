@app.controller 'AdminLibrariesCtrl', class extends Controller
  @inject 'Library'

  initialize: ->
    @load()
    @view =
      name: 'My Library'
      user:
        name: 'Admin'

  load: ->
    @Library.adminIndex().$promise.then((@libraries) =>)

  create: ->
    @errors = null
    @Library.adminCreate(@view).$promise.then(
      (=> @load()),
      ((response) => @errors = response.data)
    )
