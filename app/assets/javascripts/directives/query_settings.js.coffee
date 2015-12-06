@app.directive 'querySettings', ->
  templateUrl: 'query.html'
  scope:
    params: '='
  bindToController: true
  transclude: true
  controllerAs: 'ctrl'

  controller: class extends Controller

    FILTER_FIELDS:
      type:
        label: 'Type'
        type: 'enum'
      name:
        label: 'Name'
        type: 'string'
      taken_at:
        label: 'Date Taken'
        type: 'date'
      imported_at:
        label: 'Date Imported'
        type: 'date'

    OPERATORS:
      enum:
        eq: 'is'
        ne: 'is not'
      string:
        eq: 'equals'
        contains: 'contains'
      date:
        eq: 'on'
        ge: 'on or after'
        gt: 'after'
        le: 'on or before'
        lt: 'before'

    ENUM_OPTIONS:
      type:
        Photo: 'Photo'
        Video: 'Video'

    @inject 'Library', 'tagsInputBind'

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
