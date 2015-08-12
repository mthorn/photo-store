@app.filter 'bytes', ->
  SUFFIXES = [ 'B', 'KiB', 'MiB', 'GiB', 'TiB' ]
  (input) ->
    value = parseInt(input || 0)
    for suffix, i in SUFFIXES
      if value < 1024 || i == SUFFIXES.length - 1
        return "#{Math.floor(value * 100) / 100}#{suffix}" # 2 decimal places
      else
        value /= 1024
