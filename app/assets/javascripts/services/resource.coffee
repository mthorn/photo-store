@app.config [
  '$provide',
  ($provide) ->
    $provide.decorator '$resource', [
      '$delegate',
      ($delegate) ->
        (url, paramDefaults = {}, actions = {}, options = {}) ->

          # extract params from URL, conventionally param name in URL matches model attribute
          re = /:[a-z_]+/g
          while match = re.exec(url)
            param = match[0].substring(1)
            paramDefaults[param] ||= "@#{param}"

          # default update action for rails resources
          actions['update'] ||= { method: 'PUT' }

          resource = $delegate(url, paramDefaults, actions, options)
          resource.$url = url

          # Determine the URL for the resource based on the current attributes.
          # If a parameter is undefined, it is substituted with a blank string,
          # extra slashes are removed.
          resource::url = ->
            url.replace /\/?:([a-z_]+)/g, (m) =>
              i = m.indexOf(':')
              attr = m.substring(i + 1)
              if (val = @[attr])?
                m.substring(0, i) + val
              else
                ''

          # Decorate each mutator method (non-GETs). If first argument passed
          # to method is a plain object, extend the resource object with it,
          # then call original method with that object removed from the
          # argument list.
          # mutators = [ 'save', 'remove', 'delete' ].concat(
            # Object.keys(actions).filter((action) -> actions[action].method != 'GET'))
          # for mutator in mutators.uniq()
            # resource::decorate "$#{mutator}", (originalMutator, args) ->
              # angular.extend(@, args.shift()) if angular.isObject(args.first())
              # originalMutator.apply(@, args)

          resource
    ]
]

