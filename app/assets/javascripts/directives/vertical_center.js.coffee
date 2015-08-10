@app.directive 'verticalCenter', [
  '$window',
  ($window) ->
    (scope, element) ->

      container = element.parent()

      setMargin = (containerHeight, elementHeight) ->
        containerHeight = container.height() if typeof containerHeight != 'number'
        elementHeight = element.height() if typeof elementHeight != 'number'
        element.css('margin-top', "#{(containerHeight - elementHeight) / 2}px")

      scope.$watch(
        (-> [ container.height(), element.height() ]),
        (([ containerHeight, elementHeight ]) -> setMargin(containerHeight, elementHeight)),
        true
      )

      $($window).on('resize', setMargin)
      element.on('load', setMargin)

      scope.$on '$destroy', ->
        $($window).off('resize', setMargin)
        element.off('load', setMargin)
]
