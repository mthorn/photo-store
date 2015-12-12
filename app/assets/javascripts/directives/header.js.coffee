@app.directive 'header', ->
  templateUrl: 'header.html'
  scope: true
  controllerAs: 'ctrl'
  controller: class extends Controller
    @inject '$location', '$modal', 'User', 'Library', 'config', 'selection'

    library: => @Library.current
    libraryId: -> @library()?.id
    path: -> @location.path()
    pathStartsWith: (str) -> _.startsWith(@path(), str)
    pathEndsWith: (str) -> _.endsWith(@path(), str)

    settings: ->
      @modal.open
        templateUrl: 'settings.html'
        controller: 'SettingsCtrl as ctrl'
        resolve:
          library: @library

    roles: ->
      @modal.open
        templateUrl: 'roles.html'
        controller: 'RolesCtrl as ctrl'
        resolve:
          library: @library
        size: 'lg'

    profile: ->
      @modal.open
        templateUrl: 'profile.html'
        controller: 'ProfileCtrl as ctrl'

    password: ->
      @modal.open
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
