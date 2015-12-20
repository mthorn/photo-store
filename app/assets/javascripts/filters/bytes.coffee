@app.filter 'bytes', [
  '$window',
  ($window) ->
    SUFFIXES = [ 'B', 'KiB', 'MiB', 'GiB', 'TiB' ]
    (input) ->
      value = Math.max(parseInt(input || 0), 0)
      for suffix, i in SUFFIXES
        if value < 1024 || i == SUFFIXES.length - 1
          return $window.sprintf("%.02f%s", value, suffix)
        else
          value /= 1024
]
