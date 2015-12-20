@app.controller 'PasswordCtrl', class PasswordCtrl extends Controller

  @inject '$http', '$window'

  initialize: ->
    @view = password: '', password_confirmation: ''

  save: ->
    @errors = null
    @http(
      method: 'PUT'
      url: '/api/user.json'
      data: @view
    ).then(=>
      @window.location.reload()
    ).catch((response) =>
      @errors = response.data
    )
