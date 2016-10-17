@app.directive 'whileLoading', [
  '$parse',
  ($parse) ->

    scope: true
    link: (scope, element, attrs) ->
      img = null
      callback = $parse(attrs.setLoading)

      remove = ->
        element.show()
        callback(scope, loading: false)
        img?.remove()
        img = null
        element.off 'load', remove

      attrs.$observe 'src', ->
        element.hide()
        callback(scope, loading: true)
        unless img?
          img = $("<img src='#{attrs.whileLoading}'>").insertAfter(element)
        element.on 'load', -> scope.$applyAsync(remove)

      scope.$on '$destroy', remove
]
