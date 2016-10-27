@app.component 'psAdminLibraries',

  template: """
    <h2>Libraries</h2>
    <table class='table'>
      <thead>
        <th>ID</th>
        <th>Name</th>
      </thead>
      <tbody>
        <tr ng-repeat='library in $ctrl.libraries track by library.id'>
          <td>{{library.id}}</td>
          <td>{{library.name}}</td>
        </tr>
      </tbody>
    </table>
    <h3>New Library</h3>
    <div class='form form-horizontal'>
      <div class='form-group row-fluid'>
        <label class='control-label col-sm-3' for='name'>Name</label>
        <div class='col-sm-9' errors='$ctrl.errors.name'>
          <input class='form-control' id='name' ng-model='$ctrl.view.name' type='text'>
        </div>
      </div>
      <div class='form-group row-fluid'>
        <label class='control-label col-sm-3' for='admin_email'>Admin Email</label>
        <div class='col-sm-9' errors='$ctrl.errors.user.email'>
          <input class='form-control' id='admin_email' ng-model='$ctrl.view.user.email' type='email'>
        </div>
      </div>
      <div class='form-group row-fluid'>
        <label class='control-label col-sm-3' for='admin_name'>Admin Name</label>
        <div class='col-sm-9' errors='$ctrl.errors.user.name'>
          <input class='form-control' id='admin_name' ng-model='$ctrl.view.user.name' type='text'>
        </div>
      </div>
      <div class='form-group row-fluid'>
        <div class='col-sm-offset-3 col-sm-9'>
          <button class='btn btn-default' ng-click='$ctrl.create()'>Create</button>
        </div>
      </div>
    </div>
    <h3>Run Job</h3>
    <div class='form form-horizontal'>
      <div class='form-group row-fluid'>
        <label class='control-label col-sm-3' for='job'>Job</label>
        <div class='col-sm-4'>
          <select class='form-control' ng-model='selectedJob'>
            <option value='SetCoordinatesJob'>SetCoordinatesJob</option>
            <option value='SetMd5sumJob'>SetMd5sumJob</option>
            <option value='SetTakenAtJob'>SetTakenAtJob</option>
            <option value='CreateMissingTranscodesJob'>CreateMissingTranscodesJob</option>
            <option value='BackupDatabaseJob'>BackupDatabaseJob</option>
          </select>
        </div>
        <div class='col-sm-1'>
          <button class='btn btn-default' ng-click='$ctrl.runJob(selectedJob)'>Run</button>
        </div>
        <div class='col-sm-4'>{{$ctrl.jobStatus}}</div>
      </div>
    </div>
  """

  controller: class extends BaseCtrl
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
