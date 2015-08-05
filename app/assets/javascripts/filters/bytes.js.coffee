@app.filter 'bytes', ->
  SUFFIXES = [ 'B', 'kB', 'MB', 'GB', 'TB' ]
  (input) ->
    return '' unless input

    value = parseInt input
    for suffix, i in SUFFIXES
      if value < 1024 || i == SUFFIXES.length - 1
        return "#{Math.round value}#{suffix}"
      else
        value /= 1024
