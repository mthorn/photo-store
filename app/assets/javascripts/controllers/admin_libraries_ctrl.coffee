@app.controller 'AdminLibrariesCtrl', class extends BaseCtrl
  @inject 'Library', '$http', '$interval'

  initialize: ->
    @load()
    @view =
      name: 'My Library'
      user:
        name: 'Admin'

    @reloader = @$interval(@load, 60000)

  load: =>
    @Library.adminIndex().$promise.then((@libraries) =>)

  create: ->
    @errors = null
    @Library.adminCreate(@view).$promise.then(@load, ((response) => @errors = response.data))

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

  '$on($destroy)': =>
    @$interval.cancel(@reloader)
