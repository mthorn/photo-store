@app.factory 'placeholderImageUrl', [
  '$window',
  ($window) ->

    size = 20

    canvas = $window.document.createElement('canvas')
    canvas.width = canvas.height = size
    ctx = canvas.getContext('2d')

    ctx.fillStyle = '#ffffff'
    ctx.fillRect 0, 0, size, size

    canvas.toDataURL 'image/png'
]
