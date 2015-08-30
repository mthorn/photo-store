@app.filter 'tagCount', [
  'Library',
  (Library) ->
    (tag) ->
      Library.current.tag_counts[if tag[0] == '-' then tag.slice(1) else tag] ? 0
]
