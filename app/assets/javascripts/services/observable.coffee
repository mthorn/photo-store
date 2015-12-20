@app.factory 'Observable', ->

  trigger: (event, data) ->
    if callbacks = @listeners?[event]
      for callback in callbacks
        callback(data)
    data

  on: (event, callback) ->
    ((@listeners ?= {})[event] ?= []).push(callback)

  off: (event, callback) ->
    if callbacks = @listeners?[event]
      @listeners[event] = _.without(callbacks, callback)
