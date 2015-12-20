@app.filter 'fullErrorMessages', ->
  (input) ->
    result = []
    for field, messages of input
      for message in messages
        result.push("#{field} #{message}")
    result.join(', ')
