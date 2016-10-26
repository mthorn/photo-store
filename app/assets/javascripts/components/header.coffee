@app.component 'psHeader',

  template: """
    <nav class='navbar navbar-default'>
      <div class='container-fluid'>
        <div class='navbar-header'>
          <button aria-expanded='false' class='navbar-toggle collapsed' data-target='#nav_content' data-toggle='collapse' type='button'>
            <span class='sr-only'>Toggle navigation</span>
            <span class='icon-bar'></span>
            <span class='icon-bar'></span>
            <span class='icon-bar'></span>
          </button>
          <a class='navbar-brand'>
            {{$ctrl.library().name}}
          </a>
        </div>
        <div class='collapse navbar-collapse' id='nav_content'>
          <ul class='nav navbar-nav'>
            <li ng-class='{ active: $ctrl.pathEndsWith("/gallery") }'>
              <a ng-href='/{{$ctrl.libraryId()}}/gallery'>Gallery</a>
            </li>
            <li ng-class='{ active: $ctrl.pathEndsWith("/slides") }'>
              <a ng-href='/{{$ctrl.libraryId()}}/slides'>Slideshow</a>
            </li>
            <li ng-show='$ctrl.library()["can_upload?"]'>
              <a ng-click='$ctrl.upload()'>Upload</a>
            </li>
            <li ng-class='{ active: $ctrl.pathStartsWith("/admin/") }' ng-show='$ctrl.User.me.admin'>
              <a href='/admin/libraries'>Admin</a>
            </li>
          </ul>
          <ul class='nav navbar-nav navbar-right'>
            <li class='dropdown'>
              <a aria-expanded='false' aria-haspopup='true' class='dropdown-toggle' data-toggle='dropdown' role='button'>
                Selection
                <span class='badge' ng-hide='$ctrl.selection.isEmpty()'>{{$ctrl.selection.count()}}</span>
                <span class='caret'></span>
              </a>
              <ul class='dropdown-menu'>
                <li>
                  <a ng-click='$ctrl.selection.enabled = ! $ctrl.selection.enabled'>
                    {{$ctrl.selection.enabled && 'Disable' || 'Enable'}}
                  </a>
                </li>
                <li>
                  <a ng-click='$ctrl.selection.manualDeselect("toggle")'>
                    <i class='fa' ng-class='{ "fa-check": $ctrl.selection.manualDeselect() }'></i>
                    Click to de-select
                  </a>
                </li>
                <li class='divider' role='separator'></li>
                <li>
                  <a ng-click='$ctrl.selection.clear()' shortcut='c'>
                    Clear
                  </a>
                </li>
                <li ng-show='$ctrl.selection.isPageAvailable()'>
                  <a ng-click='$ctrl.selection.togglePage(true)' shortcut='p'>
                    Select all on page
                  </a>
                </li>
                <li ng-show='$ctrl.selection.isAllPagesAvailable()'>
                  <a ng-click='$ctrl.selection.toggleAllPages(true)' shortcut='a'>
                    Select all on all pages
                  </a>
                </li>
                <li ng-show='$ctrl.selection.isPageAvailable() && $ctrl.selection.manualDeselect()'>
                  <a ng-click='$ctrl.selection.togglePage(false)'>
                    De-select all on page
                  </a>
                </li>
                <li ng-show='$ctrl.selection.isAllPagesAvailable() && $ctrl.selection.manualDeselect()'>
                  <a ng-click='$ctrl.selection.toggleAllPages(false)'>
                    De-select all on all pages
                  </a>
                </li>
                <li class='divider' role='separator'></li>
                <li ng-class='{ disabled: $ctrl.selection.isEmpty() }'>
                  <a ng-click='$ctrl.selection.editTags()' shortcut='t'>
                    Add/Remove Tags
                  </a>
                </li>
                <li ng-class='{ disabled: $ctrl.selection.isEmpty() }'>
                  <a ng-click='$ctrl.selection.review()'>
                    Review
                  </a>
                </li>
                <li ng-class='{ disabled: $ctrl.selection.isEmpty() }'>
                  <a ng-click='$ctrl.selection.deleteSelected()' shortcut='d'>
                    Delete
                  </a>
                </li>
              </ul>
            </li>
            <li class='dropdown'>
              <a aria-expanded='false' aria-haspopup='true' class='dropdown-toggle' data-toggle='dropdown' role='button'>
                Library
                <span class='caret'></span>
              </a>
              <ul class='dropdown-menu'>
                <li ng-class='{ disabled: ! $ctrl.library() }'>
                  <a ng-click='$ctrl.settings()'>
                    Settings
                  </a>
                </li>
                <li ng-show='$ctrl.library()["owner?"]'>
                  <a ng-click='$ctrl.roles()'>
                    Roles
                  </a>
                </li>
                <li ng-show='$ctrl.library()["owner?"]'>
                  <a ng-click='$ctrl.members()'>
                    Members
                  </a>
                </li>
                <li class='divider' ng-if-start='$ctrl.library().deleted_count' role='separator'></li>
                <li class='dropdown-header'>
                  {{$ctrl.library().deleted_count}} deleted items
                </li>
                <li>
                  <a ng-href='/{{$ctrl.libraryId()}}/gallery?deleted=true'>
                    Review
                  </a>
                </li>
                <li>
                  <a ng-click='$ctrl.removeDeleted()'>
                    Remove
                  </a>
                </li>
                <li ng-if-end>
                  <a ng-click='$ctrl.restoreDeleted()'>
                    Restore
                  </a>
                </li>
                <li class='divider' ng-if-start='$ctrl.Library.mine.length > 1' role='separator'></li>
                <li ng-if-end ng-repeat='library in $ctrl.Library.mine track by library.id'>
                  <a ng-href='/{{library.id}}/gallery'>
                    {{library.name}}
                  </a>
                </li>
              </ul>
            </li>
            <li class='dropdown'>
              <a aria-expanded='false' aria-haspopup='true' class='dropdown-toggle' data-toggle='dropdown' role='button'>
                {{$ctrl.User.me.name}}
                <span class='caret'></span>
              </a>
              <ul class='dropdown-menu'>
                <li>
                  <a ng-click='$ctrl.profile()'>
                    Profile
                  </a>
                </li>
                <li>
                  <a ng-click='$ctrl.password()'>
                    Change Password
                  </a>
                </li>
                <li>
                  <a data-method='delete' href='/users/sign_out' target='_self'>
                    Sign out
                  </a>
                </li>
              </ul>
            </li>
            <li ng-show='$ctrl.isFullScreenAvailable() && ! $ctrl.isFullScreenActive()'>
              <a ng-click='$ctrl.enterFullScreen()'>
                <i class='fa fa-expand'></i>
              </a>
            </li>
            <li ng-show='$ctrl.isFullScreenActive()'>
              <a ng-click='$ctrl.exitFullScreen()'>
                <i class='fa fa-compress'></i>
              </a>
            </li>
          </ul>
        </div>
      </div>
    </nav>
  """

  controller: class extends BaseCtrl
    @inject '$location', '$uibModal', '$document', 'User', 'Library',
      'selection', 'uploader'

    $onInit: ->
      $html = @document.find('html')
      $html.on 'fullscreenchange webkitfullscreenchange mozfullscreenchange', =>
        $html.toggleClass('fullscreen', @isFullScreenActive())

    library: => @Library.current
    libraryId: -> @library()?.id
    path: -> @location.path()
    pathStartsWith: (str) -> _.startsWith(@path(), str)
    pathEndsWith: (str) -> _.endsWith(@path(), str)

    settings: ->
      @uibModal.open
        component: 'modalSettings'
        resolve:
          library: @library

    roles: ->
      @uibModal.open
        component: 'modalRoles'
        resolve:
          library: @library
        size: 'lg'

    members: ->
      @uibModal.open
        component: 'modalMembers'
        resolve:
          library: @library
        size: 'lg'

    profile: ->
      @uibModal.open
        component: 'modalProfile'

    password: ->
      @uibModal.open
        component: 'modalPassword'

    removeDeleted: ->
      @library().$removeDeleted().then =>
        if (params = @location.search()).deleted == 'true'
          @location.search _.omit(params, 'deleted')
        else
          @Library.trigger('change')

    restoreDeleted: ->
      @library().$restoreDeleted().then =>
        if (params = @location.search()).deleted == 'true'
          @location.search _.omit(params, 'deleted')
        else
          @Library.trigger('change')

    enterFullScreen: ->
      el = @document[0].documentElement
      for method in [ 'requestFullscreen', 'webkitRequestFullscreen', 'mozRequestFullscreen' ]
        if el[method]?
          el[method]()
          break

    exitFullScreen: ->
      document = @document[0]
      for method in [ 'exitFullscreen', 'webkitExitFullscreen', 'mozExitFullscreen' ]
        if document[method]?
          document[method]()
          break

    isFullScreenAvailable: ->
      document = @document[0]
      result = document.fullscreenEnabled ? document.webkitFullscreenEnabled ? document.mozFullscreenEnabled

    isFullScreenActive: ->
      document = @document[0]
      (document.fullscreenElement || document.webkitFullscreenElement || document.mozFullscreenElement)?

    upload: ->
      if ! @fileInput?
        @fileInput = $('<input type="file" multiple accept="image/*,video/*">')
        @fileInput.on 'change', ->
          if (files = _.map(fileInput[0].files)).length
            @uploader.import(files)
            @fileInput.val('')
      @fileInput.click()
      null
