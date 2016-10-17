@app.component 'psSlideshow',

  template: """
    <div class='slides-filters' ng-class='{ open: filtersOpen, closed: ! filtersOpen }' ng-mouseenter='filtersOpen = true' ng-mouseleave='filtersOpen = false'>
      <ps-filters ng-show='filtersOpen' params='$ctrl.params'></ps-filters>
      <i class='fa fa-search' ng-hide='filtersOpen'></i>
    </div>
    <div class='slides' ng-if='$ctrl.items.count != 0' ng-swipe-left='$ctrl.change(1)' ng-swipe-right='$ctrl.change(-1)'>
      <div class='dropdown' is-open='dropdown' ng-mouseleave='dropdown = false' uib-dropdown>
        <span class='icon-type' ng-mouseenter='dropdown = true'>
          <i class='fa fa-stack-1x icon-type' ng-class='{ "fa-camera": upload.type == "Photo", "fa-video-camera": upload.type == "Video" }'></i>
        </span>
        <ul aria-labelledby='upload{{upload.id}}' class='dropdown-menu' template-url='upload_dropdown.html' uib-dropdown-menu></ul>
      </div>
      <img ng-if='upload.state == "ready" && upload.type == "Photo"' ng-src='{{ upload.large_url }}'>
      <video autoplay click-play-pause controls ng-if='upload.state == "ready" && upload.type == "Video"' ng-poster='{{ upload.large_url }}' ng-src='{{ upload.video_url }}'></video>
      <div class='processing text-center' ng-if='upload.state == "process"'>
        <i class='fa fa-spinner fa-spin'></i>
      </div>
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

  controller: class extends IndexCtrl
    @inject 'imageCache'

    LIMIT = 100
    CACHE_AHEAD = 5
    SEARCH_PARAMS = [ 'i', 'order', 'tags', 'filters' ]

    initialize: ->
      super
      @scope.$watch (=> @upload()), (upload) =>
        @scope.upload = upload
        @updateCache()

      @initSearch({
        i: 0
        order: ''
        tags: ''
        filters: '[]'
      })

    queryParams: ->
      angular.extend _.pick(@params, 'order', 'tags', 'filters'),
        limit: LIMIT
        offset: @getOffset()

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

    '$watchChange(params)': (params, oldParams) ->
      if params.i == oldParams.i && params.i != 0
        @params.i = 0
      else
        @search(@params)

    '$searchChange(i)': (search, oldSearch) ->
      @params = _.pick(search, SEARCH_PARAMS)
      @fetch() if @getOffset(search.i) != @getOffset(oldSearch.i)

    '$searchChange(order, tags, filters)': (search) ->
      @params = _.pick(search, SEARCH_PARAMS)
      @fetch()
