@app.directive 'querySettings', ->
  templateUrl: 'query.html'
  scope:
    params: '='
  bindToController: true
  transclude: true
  controllerAs: 'ctrl'

  controller: class extends Controller

    FILTER_FIELDS:
      name: 'Name'
      taken_at: 'Date Taken'
      imported_at: 'Date Imported'

    OPERATORS:
      string:
        eq: 'equals'
        contains: 'contains'
      date:
        eq: 'on'
        ge: 'on or after'
        gt: 'after'
        le: 'on or before'
        lt: 'before'

    @inject 'Library', 'tagsInputBind'

    suggestTags: (query) ->
      if negative = query[0] == '-'
        query = query.slice(1)
      Object.keys(@Library.current.tag_counts).
        filter((tag) -> tag.slice(0, query.length) == query).
        sort((a, b) -> if a < b then -1 else if a > b then 1 else 0).
        map((tag) -> if negative then "-#{tag}" else tag)

    fieldType: (field) ->
      if field.match /_at$/
        'date'
      else
        'string'

    '$watch(params)': =>
      @unbindTags?()
      return unless @params
      @unbindTags = @tagsInputBind([ @, 'tags' ], [ @params, 'tags' ])

    '$watch(newFilter)': =>
      return unless @newFilter
      @filters ?= []
      @filters.push(field: @newFilter)
      @newFilter = null

    '$watchEquality(filters)': =>
      unless @filters
        delete @params.filters
        return

      filters = JSON.stringify(@filters.
        filter((filter) -> filter.op && filter.value).
        map((filter) -> _.pick(filter, 'field', 'op', 'value')))

      if filters && filters != '[]'
        @params.filters = filters
      else
        delete @params.filters

    '$watch(params.filters)': (filters) =>
      return unless filters
      @filters = JSON.parse(filters)

    '$on($destroy)': =>
      @unbindTags?()
