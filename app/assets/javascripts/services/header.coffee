@app.factory 'header', [
  'SearchObserver',
  (SearchObserver) ->

    showFilters: false
    currentUpload: null

    newFiltersObserver: (scope) ->
      SearchObserver(scope,
        order: ''
        tags: ''
        filters: '[]'
      )
]
