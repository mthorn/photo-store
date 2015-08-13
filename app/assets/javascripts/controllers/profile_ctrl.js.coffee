@app.controller 'ProfileCtrl', class ProfileCtrl extends Controller

  @inject '$http', '$window', 'User'

  initialize: ->
    @user = @User.me
    @password = password: '', password_confirmation: ''

  updateProfile: ->
    @errors = null
    @user.$update().catch((response) => @errors = response.data)

  updatePassword: ->
    @passwordErrors = null
    @http(
      method: 'PUT'
      url: '/api/user.json'
      data: @password
    ).then(=>
      @window.location.reload()
    ).catch((response) =>
      @passwordErrors = response.data
    )
