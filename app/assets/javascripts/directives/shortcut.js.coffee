@app.directive 'shortcut', [
  '$window',
  ($window) ->

    shortcuts = {}

    $($window.document.body).on('keypress', (event) ->
      return if $(event.target).is('input, textarea')
      key = String.fromCharCode(event.which)
      if key && (element = shortcuts[key])?
        element.click()
    )

    (scope, element, attrs) ->
      key = attrs.shortcut
      shortcuts[key] = element
      scope.$on '$destroy', -> delete shortcuts[key]

      html = element.html().split(/(?=<|>)/)
      if (i = _.findIndex(html, (e) => e[0] != '<' && e.indexOf(key.toUpperCase()) != -1)) != -1
        html[i] = html[i].replace(key.toUpperCase(), "<u>#{key.toUpperCase()}</u>")
      else if (i = _.findIndex(html, (e) => e[0] != '<' && e.indexOf(key) != -1)) != -1
        html[i] = html[i].replace(key, "<u>#{key}</u>")
      element.html(html.join(''))
]
