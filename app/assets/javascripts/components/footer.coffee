@app.component 'psFooter',

  template: """
    <div class='text-right text-warning' ng-show='$ctrl.up.errors.length'>
      <a href='#' ng-click='$ctrl.up.viewErrors()'>
        {{$ctrl.up.errors.length}} files failed to upload.
      </a>
      <button class='btn btn-default' ng-click='$ctrl.up.retryAll()'>Retry</button>
      <button class='btn btn-default' ng-click='$ctrl.up.errors = []'>Clear</button>
    </div>
    <h1 class='file-drop-target bg-primary' file-drop='$ctrl.up.import(files)' ng-class='{ checking: $ctrl.up.checking > 0 }'>
      <span class='reading'>
        <i class='fa fa-spin fa-spinner'></i>
        Preparing files...
      </span>
      <span class='hover' ng-hide='$ctrl.up.progress.count'>
        Drop files to start import!
      </span>
      <span class='hover' ng-show='$ctrl.up.progress.count'>
        Drop files to add to import!
      </span>
    </h1>
    <div class='bg-info text-center' ng-show='$ctrl.up.progress'>
      <button class='btn btn-default' ng-click='$ctrl.up.pause()' ng-hide='$ctrl.up.queue.isPaused'>Pause</button>
      <button class='btn btn-default' ng-click='$ctrl.up.unpause()' ng-show='$ctrl.up.queue.isPaused'>Continue</button>
      <button class='btn btn-default' ng-click='$ctrl.up.cancel()'>Cancel</button>
      Uploading:
      <span>{{$ctrl.up.progress.done + 1}} / {{$ctrl.up.progress.count}} files,</span>
      <span>{{$ctrl.up.progress.loaded + ($ctrl.up.current.progress.loaded || 0) | bytes}} / {{$ctrl.up.progress.total | bytes}},</span>
      <span ng-show='$ctrl.up.skipped' uib-tooltip='Files are skipped if they are already in the library.'>
        {{$ctrl.up.skipped}} files skipped,
      </span>
      <span ng-show='$ctrl.up.timeRemaining()'>
        {{$ctrl.up.timeRemaining() | duration}} remaining,
        {{$ctrl.up.uploadRate() | bytes}}/s
      </span>
      <span ng-hide='$ctrl.up.timeRemaining()'>
        calculating time remaining...
      </span>
    </div>
    <div class='ng-info text-center' ng-show='! $ctrl.up.progress && $ctrl.up.skipped'>
      Import complete, {{$ctrl.up.skipped}} files that are already in the library were skipped.
      <button class='btn btn-default' ng-click='$ctrl.up.skipped = 0'>Close</button>
    </div>
    <uib-progressbar max='$ctrl.up.progress.total' ng-if='$ctrl.up.progress' value='$ctrl.up.progress.loaded + ($ctrl.up.current.progress.loaded || 0)'></uib-progressbar>
  """

  controller: class extends BaseCtrl
    @inject 'uploader'

    initialize: ->
      @up = @uploader
