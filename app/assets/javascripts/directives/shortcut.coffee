@app.directive 'shortcut', [
  '$window', '$parse',
  ($window,   $parse) ->

    shortcuts = {}

    $($window.document.body).on('keydown', (event) ->
      return if $(event.target).is('input, textarea')
      debugger
      shortcuts[event.which]?()
    )

    (scope, element, attrs) ->
      codes = attrs.shortcut.split(',').map((k) ->
        if k.match /\d\d+/
          parseInt(k, 10)
        else
          k.toUpperCase().charCodeAt(0)
      )

      callback =
        if attrs.ngClick
          fn = $parse(attrs.ngClick)
          -> scope.$applyAsync -> fn(scope)
        else
          -> element.click()

      shortcuts[code] = callback for code in codes
      scope.$on '$destroy', ->
        delete shortcuts[code] for code in codes

      upperKey = String.fromCharCode(codes[0])
      lowerKey = upperKey.toLowerCase()
      html = element.html().split(/(?=<|>)/)
      if (i = _.findIndex(html, (e) => e[0] != '<' && e.indexOf(upperKey) != -1)) != -1
        html[i] = html[i].replace(upperKey, "<u>#{upperKey}</u>")
      else if (i = _.findIndex(html, (e) => e[0] != '<' && e.indexOf(lowerKey) != -1)) != -1
        html[i] = html[i].replace(lowerKey, "<u>#{lowerKey}</u>")
      element.html(html.join(''))
]
