@app.component 'psGallery',

  template: """
    <div class='gallery-filters row'>
      <div class='col-xs-10 col-xs-offset-1' ng-class='{ "col-sm-10": $ctrl.filtersOpen, "col-sm-2": ! $ctrl.filtersOpen, closed: ! $ctrl.filtersOpen }'>
        <uib-accordion>
          <div is-open='$ctrl.filtersOpen' uib-accordion-group>
            <uib-accordion-heading>
              Options
              <i class='pull-right fa' ng-class='{ "fa-chevron-down": $ctrl.filtersOpen, "fa-chevron-right": ! $ctrl.filtersOpen }'></i>
            </uib-accordion-heading>
            <ps-filters params='$ctrl.params'>
              <div class='form-group'>
                <label class='control-label col-sm-3' for='limit'>Per page</label>
                <div class='col-sm-9'>
                  <select class='form-control' id='limit' ng-model='$ctrl.params.limit' ng-options='e.value as e.label for e in $ctrl.limitOptions'></select>
                </div>
              </div>
            </ps-filters>
          </div>
        </uib-accordion>
      </div>
    </div>
    <div ng-if='$ctrl.items.length != 0'>
      <div class='text-center'>
        <ul boundary-links='true' class='top' first-text='«' items-per-page='$ctrl.params.limit' last-text='»' max-size='5' next-text='›' ng-if='$ctrl.items' ng-model='$ctrl.params.page' previous-text='‹' total-items='$ctrl.items.count' uib-pagination></ul>
        <a class='pagination-status hidden-xs' href='#' ng-click='$ctrl.fetch()' ng-hide='$ctrl.fetching' uib-tooltip='Click to Refresh'>
          {{$ctrl.items.count}} found
        </a>
        <span class='pagination-status' ng-show='$ctrl.fetching'>
          <i class='fa fa-refresh fa-spin'></i>
        </span>
      </div>
      <div class='gallery row'>
        <div class='gallery-gutters col-xs-6 col-sm-4 col-md-3 col-lg-2' ng-repeat='upload in $ctrl.items track by upload.id'>
          <div class='gallery-item' ng-class='{ selected: $ctrl.selection.isSelected(upload.id) }' ng-click='$ctrl.click($event, upload)' ng-dblclick='$ctrl.dblclick($event, upload)' ng-switch='upload.state'>
            <div class='dropdown' uib-dropdown>
              <a class='icon-type' href='#' id='upload{{::upload.id}}' uib-dropdown-toggle>
                <i class='fa' ng-class='{ "fa-camera": upload.type == "Photo", "fa-video-camera": upload.type == "Video" }'></i>
              </a>
              <ul aria-labelledby='upload{{::upload.id}}' class='dropdown-menu' template-url='upload_dropdown.html' uib-dropdown-menu></ul>
            </div>
            <div class='processing text-center' ng-if='upload.isLoading'>
              <i class='fa fa-4x fa-spinner fa-spin'></i>
            </div>
            <img ng-src='{{ upload.gallery_url }}' ng-switch-when='ready' set-loading='upload.isLoading = loading' while-loading='{{ $ctrl.placeholderImageUrl }}'>
            <div class='processing text-center' ng-switch-when='process'>
              <i class='fa fa-4x fa-spinner fa-spin'></i>
            </div>
            <img ng-src='{{ $ctrl.placeholderImageUrl }}' ng-switch-when='process'>
          </div>
        </div>
      </div>
      <div class='text-center'>
        <ul boundary-links='true' class='top' first-text='«' items-per-page='$ctrl.params.limit' last-text='»' max-size='5' next-text='›' ng-if='$ctrl.items' ng-model='$ctrl.params.page' previous-text='‹' total-items='$ctrl.items.count' uib-pagination></ul>
        <a class='pagination-status hidden-xs' href='#' ng-click='$ctrl.fetch()' ng-hide='$ctrl.fetching' uib-tooltip='Click to Refresh'>
          {{$ctrl.items.count}} found
        </a>
        <span class='pagination-status' ng-show='$ctrl.fetching'>
          <i class='fa fa-refresh fa-spin'></i>
        </span>
      </div>
    </div>
    <p class='text-center' ng-if='$ctrl.items.count == 0 && $ctrl.anyFilters()'>
      No items found.
    </p>
    <p class='text-center' ng-if='$ctrl.items.count == 0 && ! $ctrl.anyFilters()'>
      There are no items in your library. Drag &amp; drop some files here to add
      them to your library.
    </p>
  """

  controller: class extends IndexCtrl

    LIMIT_OPTIONS = [ 12, 24, 48, 96 ]

    @inject '$q'

    initialize: ->
      super
      @limitOptions = LIMIT_OPTIONS.map((i) -> { value: i, label: "#{i}" })

      @initSearch({
        page: 1
        limit: 48
        order: ''
        selected: false
        deleted: false
        tags: ''
        filters: '[]'
      })

    queryParams: ->
      search = @search()
      angular.extend _.pick(search, 'limit', 'order', 'selected', 'deleted', 'tags', 'filters'),
        offset: (search.page - 1) * search.limit

    pageIds: ->
      @q.when(@items.map((item) -> item.id))

    allPageIds: ->
      @query angular.extend _.omit(@queryParams(), [ 'offset', 'limit' ]),
        order: 'id-asc'
        only_id: true

    click: (event, upload) ->
      @selection.click(event, upload.id)

    dblclick: (event, upload) ->
      @uibModal.open(
        templateUrl: 'upload_lightbox.html'
        scope: angular.extend(scope = @scope.$new(), upload: upload)
      ).result.finally(->
        scope.$destroy()
      )

    '$searchChange(*)': ->
      @params = _.pick(@search(), 'page', 'limit', 'order', 'selected', 'deleted', 'tags', 'filters')
      @fetch()
