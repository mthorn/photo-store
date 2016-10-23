@app.directive 'lightboxSize', [
  '$window',
  ($window) ->
    link: (scope, element, attrs) ->
      modal = element.closest('.modal-dialog')

      $window = $($window)
      mediaWidth = mediaHeight = mediaRatio = null

      update = ->
        # 10px margin
        maxWidth = $window.width() - 20
        maxHeight = $window.height() - 20
        windowRatio = maxWidth / maxHeight

        if windowRatio <= mediaRatio
          modal.width(maxWidth).height(maxWidth / mediaRatio)
        else
          modal.width(maxHeight * mediaRatio).height(maxHeight)

      scope.$watch(attrs.lightboxSize, ((spec) ->
        return unless spec

        # 15px padding
        mediaWidth = spec.width + 30
        mediaHeight = spec.height + 30
        mediaRatio = mediaWidth / mediaHeight

        update()
      ), true)

      $window.on('resize', update)

      scope.$on '$destroy', -> $window.off('resize', update)
]
