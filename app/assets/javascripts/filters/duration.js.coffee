@app.filter 'duration', ->
  pad = (value) ->
    if value < 10
      "0#{value}"
    else
      "#{value}"

  (input) ->
    value = Math.ceil(parseInt((input || 0) / 1000))

    if value < 60
      "#{value} seconds"
    else if value < 3600
      "#{pad(Math.floor(value / 60))}:#{pad(value % 60)}"
    else if value < 86400
      "#{pad(Math.floor(value / 3600))}:#{pad(Math.floor((value % 3600) / 60))}:#{pad(value % 60)}"
    else
      days = Math.floor(value / 86400)
      hours = Math.ceil((value % 86400) / 3600)
      "#{days} #{if days == 1 then 'day' else 'days'}, #{hours} #{if hours == 1 then 'hour' else 'hours'}"
