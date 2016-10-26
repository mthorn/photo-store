@app.component 'modalErrors',

  bindings:
    resolve: '<'
    modalInstance: '<'

  template: """
    <div class='modal-header'>
      <h3 class='modal-title'>Upload Errors</h3>
    </div>
    <div class='modal-body'>
      <table class='table' ng-show='$ctrl.errors.length'>
        <tr ng-repeat='error in $ctrl.errors'>
          <td>{{error.file.name}}:</td>
          <td ng-switch='error.reason.status'>
            <span ng-switch-when='0'>
              Unable to connect to server, net connection down?
            </span>
            <span ng-switch-when='400'>
              {{error.reason.statusText}} (transient cloud provider error)
            </span>
            <span ng-switch-when='422'>
              {{error.reason.data | fullErrorMessages}}
            </span>
            <span ng-switch-when='503'>
              {{error.reason.statusText}},
              possibly means that Heroku server is unavailable, see
              <a href='https://status.heroku.com' target='_blank'>Heroku Status</a>
            </span>
            <span ng-show='error.reason.statusText' ng-switch-default>
              {{error.reason.statusText}}
            </span>
            <span ng-hide='error.reason.statusText' ng-switch-default>
              Unknown error
            </span>
          </td>
          <td>
            <button class='btn btn-default btn-skinny pull-right' ng-click='$ctrl.errors.splice($index, 1)'>Clear</button>
          </td>
          <td>
            <button class='btn btn-default btn-skinny pull-right' ng-click='$ctrl.retryAt($index)'>Retry</button>
          </td>
        </tr>
      </table>
      <p ng-hide='$ctrl.errors.length'>
        All errors resolved.
      </p>
    </div>
    <div class='modal-footer'>
      <button class='btn btn-primary' ng-click='$ctrl.modalInstance.close()'>Close</button>
    </div>
  """

  controller: class extends BaseCtrl
    $onInit: ->
      @errors = @resolve.errors
      @retryAt = @resolve.retryAt
