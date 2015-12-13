@app.directive 'header', ->
  templateUrl: 'header.html'
  scope: true
  controllerAs: 'ctrl'
  controller: class extends Controller
    @inject '$location', '$modal', 'User', 'Library', 'config', 'selection', 'uploader'

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

    members: ->
      @modal.open
        templateUrl: 'members.html'
        controller: 'MembersCtrl as ctrl'
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

  link: (scope, element, attr, ctrl) ->
    fileInput = $('<input type="file" multiple accept="image/*,video/*">')
    scope.upload = ->
      fileInput.click()
      null
    fileInput.on 'change', ->
      if (files = _.map(fileInput[0].files)).length
        ctrl.uploader.import(files)
        fileInput.val('')
