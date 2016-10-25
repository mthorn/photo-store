@app.component 'psViewUpload',

  bindings:
    upload: '<'

  template: """
    <div ng-mouseleave='$ctrl.showControls(false)'>
      <div class='transform-origin' ng-style='$ctrl.transformStyles()' ng-show='$ctrl.upload.state == "ready"'>
        <img ng-if='$ctrl.upload.type == "Photo"' ng-src='{{ $ctrl.upload.large_url }}'>
        <video autoplay
            ng-if='$ctrl.upload.type == "Video"'
            ng-init='$ctrl.videoInit()'
            ng-poster='{{$ctrl.upload.large_url}}'
            ng-src='{{$ctrl.upload.video_url}}'
            ng-mousemove='$ctrl.showControls(2000)'></video>
      </div>

      <div class='controls' ng-show='$ctrl.controlsVisible' ng-if='$ctrl.upload.type == "Video" && $ctrl.upload.state == "ready"' ng-mousemove='$ctrl.showControls(0)'>
        <a ng-click='$ctrl.videoInvoke("play")' ng-hide='$ctrl.playing'>
          <i class='fa fa-play'></i>
        </a>
        <a ng-click='$ctrl.videoInvoke("pause")' ng-show='$ctrl.playing'>
          <i class='fa fa-pause'></i>
        </a>

        <div class='scrub'>
          <div class='scale'>
            <div class='position'>
            </div>
          </div>
        </div>

        <div class='times'></div>
      </div>

      <div class='processing text-center' ng-if='$ctrl.upload.state != "ready"'>
        <i class='fa fa-spinner fa-spin'></i>
      </div>
    </div>
  """

  controller: class extends BaseCtrl
    @inject '$element', '$filter', 'schedule'

    $onInit: ->
      @element.on('click', 'video', (e) ->
        video = e.target
        if video.paused
          video.play()
        else
          video.pause()
      )

      @element.on('click', '.scrub', (e) =>
        if @video.duration
          @video.currentTime = @video.duration * e.offsetX / e.currentTarget.clientWidth
      )

    transformStyles: ->
      return unless @upload?

      w = @element.width()
      h = @element.height()

      css = {}

      if @upload.rotate
        css.transform = "rotate(#{@upload.rotate}deg)"

      if @upload.rotate in [ 90, 270 ]
        # sideways
        css.width = "#{h}px"
        css.height = "#{w}px"

        # not sure why this works
        origin = if @upload.rotate == 90 then w / 2 else h / 2
        css['transform-origin'] = "#{origin}px #{origin}px"
      else
        css.width = "#{w}px"
        css.height = "#{h}px"

      css

    videoInit: ->
      @$video = @element.find('video')
      @video = @$video[0]

      $times = $position = null
      dateFilter = @filter('date')

      @$video.
        on('play playing', (e) => @scope.$apply => @playing = true).
        on('pause', (e) => @scope.$apply => @playing = false).
        on('timeupdate', (e) =>
          current = @video.currentTime * 1000
          duration = @video.duration * 1000

          $position ?= @element.find('.controls .position')
          $position.css('width', "#{current / duration * 100}%")

          $times ?= @element.find('.controls .times')
          $times.text "#{dateFilter(current, 'mm:ss')} / #{dateFilter(duration, 'mm:ss')}"
        )

      undefined

    showControls: (ms) ->
      if ms == false
        @controlsVisible = false
      else
        @controlsVisible = true

        @showControlsTimer?.cancel()
        if ms
          @showControlsTimer = @schedule.delay ms, =>
            @controlsVisible = false

    videoInvoke: (method) ->
      @video[method]()
      undefined
