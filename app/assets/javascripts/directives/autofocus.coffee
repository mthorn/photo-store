@app.directive 'autofocus', [
  '$timeout',
  ($timeout) ->
    (scope, element) ->
      input = element.find('input')
      $timeout (-> input[0].focus()), 100
]
