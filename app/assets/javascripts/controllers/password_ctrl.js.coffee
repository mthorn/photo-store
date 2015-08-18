@app.controller 'PasswordCtrl', class PasswordCtrl extends Controller

  @inject '$http', '$window'

  initialize: ->
    @password = password: '', password_confirmation: ''

  save: ->
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
