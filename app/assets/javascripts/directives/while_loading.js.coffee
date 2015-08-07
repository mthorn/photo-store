@app.directive 'whileLoading', ->

  scope: true
  link: (scope, element, attrs) ->
    img = null

    remove = ->
      element.show()
      img?.remove()
      img = null
      element.off 'load', remove

    attrs.$observe 'src', ->
      element.hide()
      unless img?
        img = $("<img src='#{attrs.whileLoading}'>").insertAfter(element)
      element.on 'load', remove

    scope.$on '$destroy', remove
