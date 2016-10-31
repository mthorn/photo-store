@app.directive 'html', [
  '$window', '$timeout',
  ($window,   $timeout) ->

    ($scope, $element) ->

      mode = null
      timer = null
      setMode = (newMode) ->
        return if mode == newMode
        mode = newMode
        $element.toggleClass('mouse-mode', mode == 'mouse')
        $element.toggleClass('key-mode', mode == 'key')

        $timeout.cancel(timer) if timer?
        timer = null
        if mode == 'mouse'
          timer = $timeout((->
            timer = null
            setMode 'key'
          ), 10000)

      setMode 'mouse'
      $element.on('click mousemove', -> setMode 'mouse')
      $element.on('keydown', -> setMode 'key')
]
