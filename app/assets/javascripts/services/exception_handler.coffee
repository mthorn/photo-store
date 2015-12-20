@app.factory '$exceptionHandler', [
  '$log', '$injector', 'config',
  ($log,   $injector,   config) ->
    (args...) ->
      $log.error(args...)

      if config.env == 'development'
        error = args[0]
        error = error.stack ? JSON.stringify(error)
        $injector.get('$http').post('/api/jserror', error: error)
]
