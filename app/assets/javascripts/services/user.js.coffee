@app.factory 'User', [
  '$resource', '$window', 'config',
  ($resource,   $window,   config) ->
    User = $resource '/api/user.json'
    me = User.me = new User(config.user)

    zone = $window.Intl.DateTimeFormat().resolved.timeZone
    me.$update(time_zone_auto: zone) if me.time_zone_auto != zone

    User
]
