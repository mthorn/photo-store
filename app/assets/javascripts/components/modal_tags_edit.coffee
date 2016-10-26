@app.component 'modalTagsEdit',

  bindings:
    resolve: '<'
    modalInstance: '<'

  template: """
    <div class='modal-header'>
      <h3 class='modal-title'>{{$ctrl.heading}}</h3>
    </div>
    <div class='modal-body form form-horizontal'>
      <div class='form-group'>
        <div class='col-sm-12'>
          <tags-input add-on-space='true' allowed-tags-pattern='^{{$ctrl.negatives &amp;&amp; "-?" || ""}}[a-z0-9][a-z0-9&amp;-]*$' autofocus min-length='2' ng-model='$tags' tags-model='$ctrl.tags' template='tag.html'>
            <auto-complete debounce-delay='0' load-on-down-arrow='true' load-on-empty='true' min-length='1' source='$ctrl.library.suggestTags($query)' template='tag_suggestion.html'></auto-complete>
          </tags-input>
        </div>
      </div>
    </div>
    <div class='modal-footer'>
      <button busy-click='$ctrl.modalInstance.close($ctrl.tags)' class='btn btn-primary'>Save</button>
      <button class='btn btn-default' ng-click='$ctrl.modalInstance.dismiss()'>Cancel</button>
    </div>
  """

  controller: class extends BaseCtrl
    $onInit: ->
      @heading = @resolve.heading
      @tags = @resolve.tags
      @negatives = @resolve.negatives
      @library = @resolve.library
