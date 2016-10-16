@app.directive 'header', ->
  templateUrl: 'header.html'
  scope: true
  controllerAs: 'ctrl'
  controller: class extends BaseCtrl
    @inject '$location', '$uibModal', '$document', 'User', 'Library', 'config',
      'selection', 'uploader'

    initialize: ->
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
        templateUrl: 'settings.html'
        controller: 'SettingsCtrl as ctrl'
        resolve:
          library: @library

    roles: ->
      @uibModal.open
        templateUrl: 'roles.html'
        controller: 'RolesCtrl as ctrl'
        resolve:
          library: @library
        size: 'lg'

    members: ->
      @uibModal.open
        templateUrl: 'members.html'
        controller: 'MembersCtrl as ctrl'
        resolve:
          library: @library
        size: 'lg'

    profile: ->
      @uibModal.open
        templateUrl: 'profile.html'
        controller: 'ProfileCtrl as ctrl'

    password: ->
      @uibModal.open
        templateUrl: 'password.html'
        controller: 'PasswordCtrl as ctrl'

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

  link: (scope, element, attr, ctrl) ->
    fileInput = $('<input type="file" multiple accept="image/*,video/*">')
    scope.upload = ->
      fileInput.click()
      null
    fileInput.on 'change', ->
      if (files = _.map(fileInput[0].files)).length
        ctrl.uploader.import(files)
        fileInput.val('')
