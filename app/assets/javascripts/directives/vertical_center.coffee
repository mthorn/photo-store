@app.directive 'verticalCenter', [
  '$window',
  ($window) ->
    (scope, element, attrs) ->

      container = element.parent()
      image = undefined

      setMargin = ->
        imageRatio = image.width / image.height

        cWidth = container.width()
        cHeight = container.height()
        cRatio = cWidth / cHeight

        if cRatio < imageRatio
          element.css
            width: '100%'
            height: 'auto'
            margin: "#{(cHeight - (cWidth / imageRatio)) / 2}px 0"
        else
          element.css
            width: 'auto'
            height: '100%'
            margin: '0 auto'

      scope.$watch attrs.verticalCenter, (desc) ->
        image = desc

      $($window).on('resize', setMargin)
      element.on('load', setMargin)

      scope.$on '$destroy', ->
        $($window).off('resize', setMargin)
        element.off('load', setMargin)
]
