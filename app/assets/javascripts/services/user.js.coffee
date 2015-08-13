@app.factory 'User', [
  '$resource', 'config',
  ($resource,   config) ->
    User = $resource '/api/user.json'
    User.me = new User(config.user)
    User
]
