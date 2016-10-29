@app.component 'psGallery',

  template: """
    <div ng-if='$ctrl.uploads.count != 0'>
      <div id='gallery_container' class='gallery row-fluid' ng-style='$ctrl.margins()'>
        <div class='gallery-gutters col-xs-6 col-sm-4 col-md-3 col-lg-2' ng-repeat='upload in $ctrl.rendered track by upload.id'>
          <div class='gallery-item' ng-class='{ selected: $ctrl.selection.isSelected(upload.id) }' ng-click='$ctrl.click($event, upload)' ng-dblclick='$ctrl.dblclick($event, upload)' ng-switch='upload.state'>
            <div class='dropdown' uib-dropdown>
              <a class='icon-type' id='upload{{::upload.id}}' uib-dropdown-toggle>
                <i class='fa' ng-class='::{ "fa-camera": upload.type == "Photo", "fa-video-camera": upload.type == "Video" }'></i>
              </a>
              <ul aria-labelledby='upload{{::upload.id}}' class='dropdown-menu' template-url='upload_dropdown.html' uib-dropdown-menu></ul>
            </div>

            <div class='processing text-center' ng-if='upload.isLoading'>
              <i class='fa fa-4x fa-spinner fa-spin'></i>
            </div>
            <img ng-src='{{::upload.gallery_url}}' ng-style='upload.style()' ng-switch-when='ready' set-loading='upload.isLoading = loading' while-loading='{{::$ctrl.placeholderImageUrl}}'>
            <div class='processing text-center' ng-switch-when='process'>
              <i class='fa fa-4x fa-spinner fa-spin'></i>
            </div>
            <img ng-src='{{::$ctrl.placeholderImageUrl}}' ng-switch-when='process'>
          </div>
        </div>
      </div>
    </div>
    <p class='text-center' ng-if='$ctrl.uploads.count == 0 && $ctrl.anyFilters()'>
      No items found.
    </p>
    <p class='text-center' ng-if='$ctrl.uploads.count == 0 && ! $ctrl.anyFilters()'>
      There are no items in your library. Drag &amp; drop some files here to add
      them to your library.
    </p>
  """

  controller: class extends BaseCtrl

    FETCH_PAGES_AROUND = 10
    MIN_PAGES_AROUND = 2
    RENDER_PAGES_AROUND = 1

    @inject '$q', '$window', '$element', '$location', '$http', '$routeParams',
      '$uibModal', 'Library', 'SearchObserver', 'Upload', 'header', 'schedule',
      'placeholderImageUrl', 'selection'

    initialize: ->
      @seed = Math.round(Math.random() * 1000000)

      @Library.on('change', @fetch)
      @selection.ctrl = @

      @$window = $(@window)

      @fetchStartOffset = @fetchEndOffset = @renderStartOffset = @renderEndOffset = @pageOffset = 0
      @uploads = []
      @rendered = []

      if (i = parseInt(@location.hash(), 10)) > 0
        @storedScrollPosition = i

      @filtersObserver = @header.newFiltersObserver(@scope).
        observe('*', initial: false, => @fetch())
      @paramsObserver = @SearchObserver(@scope,
        selected: false
        deleted: false
      )
      @paramsObserver.observe('*', => @fetch())

    $onDestroy: ->
      @header.showFilters = false
      @destroyed = true
      @timer?.cancel()
      @Library.off('change', @fetch)
      delete @selection.ctrl

    $onInit: ->
      @header.showFilters = true

      @$window.on('resize', =>
        @updateItemHeight()
        @scrollTo(@pageOffset)
      )

      calcPageOffset = =>
        Math.max(0, Math.floor((@window.scrollY - @initialMargin) / @itemHeight) * @columns) if @itemHeight?
      @$window.on('scroll', =>
        if @pageOffset != calcPageOffset()
          @scope.$applyAsync => @pageOffset = calcPageOffset()
      )

      unwatchItemHeight = @scope.$watch(@updateItemHeight, (height) =>
        if height
          unwatchItemHeight()
          @updateRenderWindow('force')
      )

      @scope.$watch((=> @pageOffset), =>
        return if @rendered.length == 0 || ! @itemHeight

        [ maxStartOffset, minEndOffset ] = @calcWindow(MIN_PAGES_AROUND)
        @fetch(true) if maxStartOffset < @fetchStartOffset || minEndOffset > @fetchEndOffset
        @updateRenderWindow()
        @location.hash("#{@pageOffset}").replace()
      )

    query: (params) =>
      @http(
        method: 'GET'
        url: "/api/libraries/#{@routeParams.library_id}/uploads.json"
        params: params
      ).then((response) ->
        response.data
      )

    anyFilters: ->
      @params.tags || @params.filters

    tryRestoreScrollPosition: ->
      if i = @storedScrollPosition
        @schedule.delay => @scrollTo(i)
        delete @storedScrollPosition

    scrollTo: (i) ->
      i = parseInt(i, 10)
      if i == 0
        @window.scrollTo(0, s = 0)
      else
        @window.scrollTo(0, s = (i / @columns) * @itemHeight + @initialMargin)

    updateItemHeight: =>
      return if @rendered.length == 0
      if container = @element.find('#gallery_container')[0]
        @initialMargin ?= container.offsetTop
        firstChild = container.firstElementChild
        @itemHeight = $(firstChild).outerHeight(true)
        @columns = _.findIndex(container.children, (e) -> e.offsetTop != firstChild.offsetTop)
        @perPage = Math.ceil(@$window.height() / @itemHeight) * @columns
        @itemHeight

    calcWindow: (buffer) ->
      start = Math.max(0, @pageOffset - (buffer * @perPage))
      end = @pageOffset + ((buffer + 1) * @perPage)
      end = @uploads.count if @uploads.count? && end > @uploads.count
      [ (start || 0), (end || 48) ]

    updateRenderWindow: (force = false) ->
      [ newRenderStartOffset, newRenderEndOffset ] = @calcWindow(RENDER_PAGES_AROUND)
      if force || @renderStartOffset != newRenderStartOffset || @renderEndOffset != newRenderEndOffset
        @renderStartOffset = newRenderStartOffset
        @renderEndOffset = newRenderEndOffset
        @rendered = @uploads.slice(@renderStartOffset, @renderEndOffset)
        for i in [0...@renderEndOffset - @renderStartOffset]
          @rendered[i] ?= { id: i * -1, state: 'process' }
      undefined

    queryParams: ->
      angular.extend @paramsObserver.params(), @filtersObserver.params(),
        seed: @seed

    isNotReady = (upload) ->
      ! upload? || upload.state != 'ready'

    fetch: (reuseExisting = false) =>
      return if @destroyed

      if @fetching || @fetchAgain?
        return @fetchAgain = reuseExisting

      @timer?.cancel()

      if ! reuseExisting
        @uploads.length = 0
        delete @uploads.count
        if ! @storedScrollPosition && (i = parseInt(@location.hash(), 10)) > 0
          @storedScrollPosition = i

      [ @fetchStartOffset, @fetchEndOffset ] = @calcWindow(FETCH_PAGES_AROUND)

      if reuseExisting
        if @fetchStartOffset < @uploads.length
          overrideFetchStartOffset = _.findIndex(@uploads, isNotReady, @fetchStartOffset)
          overrideFetchStartOffset = @uploads.length if overrideFetchStartOffset == -1
        if @fetchEndOffset < @uploads.length
          overrideFetchEndOffset = _.findLastIndex(@uploads, isNotReady, @fetchEndOffset) + 1

      offset = overrideFetchStartOffset ? @fetchStartOffset
      limit = (overrideFetchEndOffset ? @fetchEndOffset) - offset
      return if limit <= 0

      @updateRenderWindow()

      @fetching = @query(
        angular.extend(@queryParams(), offset: offset, limit: limit)
      ).then((data) =>
        for item, i in data.items
          @uploads[offset + i] = new @Upload(item)
        @uploads.count = data.count
        @updateRenderWindow('force')
        @tryRestoreScrollPosition()

        if ! @destroyed && (@fetchAgain? || _.some(data.items, state: 'process'))
          @timer?.cancel()
          if (reuseExisting = @fetchAgain)?
            @timer = @schedule.delay(=> @fetch(reuseExisting))
          else
            @timer = @schedule.delay(5000, => @fetch(true))
        null
      ).catch(=>
        @timer?.cancel()
        @timer = @schedule.delay(5000, @fetch) unless @destroyed
      ).finally(=>
        @fetching = @fetchAgain = null
      )

    margins: ->
      if @itemHeight? && @uploads.count?
        'margin-top': "#{@renderStartOffset * @itemHeight / @columns}px"
        'margin-bottom': "#{((@uploads.count || 0) - @renderEndOffset) * @itemHeight / @columns}px"
      else
        {}

    idsBetween: (a, b) ->
      i = _.findIndex(@uploads, id: a)
      j = _.findIndex(@uploads, id: b)
      if i != -1 && j != -1
        if i < j
          uploads = @uploads.slice(i, j + 1)
        else
          uploads = @uploads.slice(j, i + 1)

        return @q.when(_.map(uploads, 'id')) if _.every(uploads)

      @query(angular.extend(@queryParams(), only_id: true)).then((ids) =>
        i = _.indexOf(ids, a)
        j = _.indexOf(ids, b)
        if i != -1 && j != -1
          if i < j
            ids.slice(i, j + 1)
          else
            ids.slice(j, i + 1)
        else
          []
      )

    pageIds: ->
      @q.when(@uploads.slice(@calcWindow(0)...).map((item) -> item.id))

    allPageIds: ->
      @query angular.extend @queryParams(),
        order: 'id-asc'
        only_id: true

    click: (event, upload) ->
      @selection.click(event, upload.id)

    dblclick: (event, upload) ->
      @uibModal.open(
        component: 'psUploadLightbox'
        resolve:
          upload: -> upload
      )
