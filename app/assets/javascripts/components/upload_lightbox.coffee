@app.component 'psUploadLightbox',

  bindings:
    resolve: '<'

  template: """
    <div class="modal-body">
      <ps-view-upload upload='$ctrl.upload'></ps-view-upload>
    </div>
  """

  controller: class extends BaseCtrl
    @inject '$window', '$element'

    MARGIN = 10
    PADDING = 15

    initialize: ->
      @$window = $(@window)

    $onInit: ->
      @upload = @resolve.upload
      @updateSize()
      @$window.on('resize', @updateSize)

    $onDestroy: ->
      @$window.off('resize', @updateSize)

    updateSize: =>
      gutterTotal = (MARGIN + PADDING) * 2
      maxWidth = @$window.width() - gutterTotal
      maxHeight = @$window.height() - gutterTotal
      windowRatio = maxWidth / maxHeight
      mediaRatio = @upload.width / @upload.height

      if @upload.rotate in [ 90, 270 ]
        mediaRatio = 1 / mediaRatio

      modal = @element.closest('.modal-dialog').css('margin', "#{MARGIN}px auto")
      body = @element.find('.modal-body').css('padding', "#{PADDING}px")
      if windowRatio <= mediaRatio
        modal.width(maxWidth + (PADDING * 2)).height((maxWidth / mediaRatio) + (PADDING * 2))
        body.width(maxWidth).height(maxWidth / mediaRatio)
      else
        modal.width((maxHeight * mediaRatio) + (PADDING * 2)).height(maxHeight + (PADDING * 2))
        body.width(maxHeight * mediaRatio).height(maxHeight)
