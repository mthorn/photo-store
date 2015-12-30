@app.controller 'AdminLibrariesCtrl', class extends Controller
  @inject 'Library', '$http'

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

  runJob: (job) ->
    @jobStatus = null
    @$http(
      method: 'POST'
      url: '/api/admin/jobs.json'
      data: { name: job }
    ).then(
      (=> @jobStatus = "#{job} started"),
      (=> @jobStatus = "#{job} error")
    )
