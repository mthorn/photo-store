@app.component 'psSlideshow',

  template: """
    <div class='slides' ng-if='$ctrl.items.count != 0' ng-swipe-left='$ctrl.change(1)' ng-swipe-right='$ctrl.change(-1)'>
      <ps-view-upload upload='upload'></ps-view-upload>

      <button class='btn' id='prev' ng-click='$ctrl.change(-1)' ng-hide='$ctrl.params.i <= 0' shortcut='h,37'>
        <i class='fa fa-chevron-left'></i>
      </button>
      <button class='btn' id='next' ng-click='$ctrl.change(1)' ng-hide='$ctrl.params.i >= $ctrl.items.count - 1' shortcut='l,32,39'>
        <i class='fa fa-chevron-right'></i>
      </button>
    </div>
    <p class='text-center' ng-if='$ctrl.items.count == 0'>
      There are no items in your library. Drag &amp; drop some files here to add
      them to your library.
    </p>
  """

  controller: class extends BaseCtrl
    @inject '$http', '$window', '$element', '$routeParams', 'Library',
      'SearchObserver', 'Upload', 'imageCache', 'header', 'schedule',
      'selection'

    LIMIT = 100
    CACHE_AHEAD = 5

    initialize: ->
      @$window = $(@window)

      @scope.$watch((=> @upload()), (upload) =>
        @header.currentUpload = @scope.upload = upload
        @updateCache()
      )

      @filtersObserver = @header.newFiltersObserver(@scope).
        observe('*', initial: false, =>
          # we want to reset to i = 0 when filter/order/tags are changed
          if @params.i != 0
            # non-'i' param changed, set i = 0 which will fire this listener again,
            # then we can update search
            @params.i = 0
          else
            @fetch()
        )

      @SearchObserver(@scope, i: 0).
        bindTo(@).
        bindAll('params').
        observe('i', (next, prev) => @fetch() if next.i == prev.i || @getOffset(@params.i) != @getOffset(prev.i))

    $onDestroy: ->
      @header.showFilters = false
      @header.currentUpload = null
      @destroyed = true
      @timer?.cancel()
      @Library.off('change', @fetch)
      delete @selection.ctrl
      @$window.off('resize', @windowResized)

    $onInit: ->
      @Library.on('change', @fetch)
      @selection.ctrl = @
      @header.showFilters = true
      @$window.on('resize', @windowResized)

    windowResized: =>
      @scope.$applyAsync()

    query: (params) =>
      @http(
        method: 'GET'
        url: "/api/libraries/#{@routeParams.library_id}/uploads.json"
        params: params
      ).then((response) ->
        response.data
      )

    fetch: =>
      return if @destroyed

      if @fetching || @fetchAgain
        return @fetchAgain = true

      @timer?.cancel()

      query = angular.extend @filtersObserver.params(),
        limit: LIMIT
        offset: @getOffset()

      @fetching = @query(query).then((data) =>
        @items = data.items.map((upload) => new @Upload(upload))
        @items.count = data.count

        if ! @destroyed && (@fetchAgain || _.some(@items, state: 'process'))
          @timer?.cancel()
          @timer = @schedule.delay(5000, @fetch)
        null
      ).catch(=>
        @timer?.cancel()
        @timer = @schedule.delay(5000, @fetch) unless @destroyed
      ).finally(=>
        @fetching = null
        @fetchAgain = false
      )

    upload: ->
      @items?[@params.i - @getOffset()]

    getOffset: (i = @params.i) ->
      Math.floor(i / LIMIT) * LIMIT

    updateCache: =>
      return unless @items?

      i = @params.i - @getOffset()
      for j in _.range(0, CACHE_AHEAD)
        if (upload = @items[i + j])?
          @imageCache.store(upload.large_url) if upload.type == 'Photo'
        if (upload = @items[i - j])?
          @imageCache.store(upload.large_url) if upload.type == 'Photo'

    change: (delta) ->
      @params.i = Math.min(Math.max(@params.i + delta, 0), @items.count - 1)

    transformStyles: ->
      if (upload = @upload()) && upload.rotate in [ 90, 270 ]
        el = @element.find('.slides')
        width = el.width()
        height = el.height()
        angular.extend upload.style(),
          width: "#{width}px";
          height: "#{height}px";
          'transform-origin': "#{height / 2}px #{height / 2}px"
