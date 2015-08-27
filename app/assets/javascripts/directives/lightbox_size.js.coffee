@app.directive 'lightboxSize', [
  '$window',
  ($window) ->
    link: (scope, element, attrs) ->
      modal = element.closest('.modal-dialog')

      $window = $($window)
      mediaWidth = mediaHeight = mediaRatio = null

      update = ->
        # 30px margin
        windowWidth = $window.width() - 60
        windowHeight = $window.height() - 60
        windowRatio = windowWidth / windowHeight

        if windowRatio <= mediaRatio
          modal.width(windowWidth).height(windowWidth / mediaRatio)
        else
          modal.width(windowHeight * mediaRatio).height(windowHeight)

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
