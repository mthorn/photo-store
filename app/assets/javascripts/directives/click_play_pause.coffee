@app.directive 'clickPlayPause', [
  '$window',
  ($window) ->

    (scope, element, attrs) ->
      elem = element[0]

      click = ->
        if elem.paused
          elem.play()
        else
          elem.pause()

      $($window).on('click', click)
      scope.$on '$destroy', ->
        $($window).off('click', click)
]
