@app.filter 'duration', ->
  (input) ->
    return '' unless input

    value = parseInt(input / 1000)
    "#{Math.round value} seconds"
