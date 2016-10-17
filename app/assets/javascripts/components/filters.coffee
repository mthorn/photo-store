@app.component 'psFilters',

  template: """
    <div class='filters form form-horizontal'>
      <ng-transclude></ng-transclude>
      <div class='form-group'>
        <label class='control-label col-sm-3' for='order'>Sorting</label>
        <div class='col-sm-9'>
          <select class='form-control' id='order' ng-model='$ctrl.params.order'>
            <option value=''>default</option>
            <option value='name-asc'>name &#8595;</option>
            <option value='name-desc'>name &#8593;</option>
            <option value='created_at-asc'>upload time &#8595;</option>
            <option value='created_at-desc'>upload time &#8593;</option>
            <option value='taken_at-asc'>time taken &#8595;</option>
            <option value='taken_at-desc'>time taken &#8593;</option>
          </select>
        </div>
      </div>
      <div class='form-group'>
        <label class='control-label col-sm-3'>Tags</label>
        <div class='col-sm-9'>
          <tags-input add-from-autocomplete-only='true' min-length='2' ng-model='$ctrl.tags' tags-model='$ctrl.params.tags' template='tag.html'>
            <auto-complete debounce-delay='0' load-on-empty='true' load-on-focus='true' min-length='1' source='$ctrl.Library.current.suggestTags($query)' template='tag_suggestion.html'></auto-complete>
          </tags-input>
        </div>
      </div>
      <div class='form-group' ng-repeat='filter in $ctrl.filters'>
        <label class='control-label col-sm-3'>
          {{$ctrl.FIELDS[filter.field].label}}
          <a class='visible-xs-inline' href='#' ng-click='$ctrl.filters.splice($index, 1)'>
            <i class='fa fa-times'></i>
          </a>
        </label>
        <div class='col-sm-3'>
          <select class='form-control' ng-model='filter.op' ng-options='key as value for (key, value) in $ctrl.OPERATORS[$ctrl.FIELDS[filter.field].type]'></select>
        </div>
        <div class='col-sm-5' ng-switch='$ctrl.FIELDS[filter.field].type'>
          <select class='form-control' ng-model='filter.value' ng-options='key as value for (key, value) in $ctrl.ENUM_OPTIONS[filter.field]' ng-switch-when='enum'></select>
          <input class='form-control' ng-model-options='{ updateOn: "blur change" }' ng-model='filter.value' ng-switch-when='string'>
          <div class='input-group' ng-switch-when='date'>
            <input class='form-control' datepicker-popup='yyyy-MM-dd' is-open='isOpen' ng-model='filter.value' type='text'>
            <span class='input-group-btn'>
              <button class='btn btn-default' ng-click='isOpen = ! isOpen' type='button'>
                <i class='fa fa-calendar'></i>
              </button>
            </span>
          </div>
        </div>
        <div class='col-sm-1 hidden-xs'>
          <a href='#' ng-click='$ctrl.filters.splice($index, 1)'>
            <i class='fa fa-times'></i>
          </a>
        </div>
      </div>
      <div class='form-group'>
        <div class='col-sm-3 col-sm-offset-3'>
          <select class='form-control' id='new_filter' ng-model='$ctrl.newFilter' ng-options='key as value.label for (key, value) in $ctrl.FIELDS'>
            <option value=''>Add a filter...</option>
          </select>
        </div>
      </div>
    </div>
  """

  bindings:
    params: '='
  transclude: true

  controller: class extends BaseCtrl

    FIELDS:
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

    @inject 'Library'

    '$watch(newFilter)': =>
      return unless @newFilter
      @filters ?= []
      @filters.push(field: @newFilter)
      @newFilter = null

    '$watchEquality(filters)': =>
      return unless @params

      @params.filters = JSON.stringify(@filters.
        filter((filter) -> filter.op && filter.value).
        map((filter) -> _.pick(filter, 'field', 'op', 'value')))

    '$watch(params.filters)': (filters) =>
      @filters = JSON.parse(filters)
