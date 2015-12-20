@app.filter 'removeLeadingHyphen', [
  '$sce',
  ($sce) ->
    (tag) ->
      if typeof tag == 'string'
        if tag[0] == '-' then tag.slice(1) else tag
      else
        html = $sce.getTrustedHtml(tag)
        if html.slice(0, 5) == '<em>-'
          $sce.trustAsHtml("<em>#{html.slice(5)}")
        else
          tag
]
