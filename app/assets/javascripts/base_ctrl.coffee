class @BaseCtrl

  @$inject = [ '$scope' ]

  # add items to controller's $inject property, automatically inherits from
  # superclasses
  @inject = (injects...) ->
    klass = @
    while klass = klass.__super__?.constructor
      injects = injects.concat(klass.$inject) if klass.$inject
    @$inject = injects

  constructor: (args...) ->
    # assign injected arguments to controller properties, strip leading '$'
    for s, i in @constructor.$inject
      @[s] = args[i]
      @[s.substring(1)] = args[i] if s[0] == '$'

    @initialize?()

    for name, fn of @
      if angular.isFunction(fn)
        # create event handlers for functions named '$on(_event_name_)',
        # create reference equality watches for functions named
        # '$watch(_expr_)' and create object equality watches for functions
        # named '$watchEquality(_expr_)'
        if (m = name.match(/^(\$(?:watch|on|watchEquality|watchChange))\((.+)\)$/))
          scopeFn = m[1]
          expr = m[2]

          do (expr, fn) =>
            fn = fn.bind(@)
            props = expr.split('.')
            expr = => _.reduce(props, ((obj, prop) -> obj?[prop]), @)

            if scopeFn == '$watchEquality'
              @scope.$watch(expr, fn, true)
            else if scopeFn == '$watchChange'
              @scope.$watch(expr, ((next, prev) ->
                fn(next, prev) unless angular.equals(next, prev)
              ), true)
            else
              @scope[scopeFn](expr, fn)
