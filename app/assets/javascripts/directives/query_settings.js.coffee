@app.directive 'querySettings', ->
  templateUrl: 'query.html'
  scope:
    params: '='
  bindToController: true
  transclude: true
  controllerAs: 'ctrl'

  controller: class extends Controller

    @inject 'Library', 'tagsInputBind'

    suggestTags: (query) ->
      if negative = query[0] == '-'
        query = query.slice(1)
      Object.keys(@Library.current.tag_counts).
        filter((tag) -> tag.slice(0, query.length) == query).
        sort((a, b) -> if a < b then -1 else if a > b then 1 else 0).
        map((tag) -> if negative then "-#{tag}" else tag)

    '$watch(params)': =>
      @unbindTags?()
      return unless @params
      @unbindTags = @tagsInputBind([ @, 'tags' ], [ @params, 'tags' ])

    '$on($destroy)': =>
      @unbindTags?()
