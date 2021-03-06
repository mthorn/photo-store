@app.factory 'User', [
  '$resource', '$window', 'config',
  ($resource,   $window,   config) ->
    User = $resource '/api/user.json'
    me = User.me = new User(config.user)

    format = $window.Intl?.DateTimeFormat()
    if format? && zone = (format.resolvedOptions?().timeZone ? format.resolved?.timeZone)
      me.$update(time_zone_auto: zone) if me.time_zone_auto != zone
    else if ! me.time_zone_auto?
      me.$update(time_zone_auto: (new Date).getTimezoneOffset())

    User
]
