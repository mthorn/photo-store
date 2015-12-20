@app.config [
  '$provide',
  ($provide) ->
    $provide.decorator '$q', [
      '$delegate', '$injector',
      ($q,          $injector) ->

        BASE_METHODS = [ 'then', 'catch', 'finally' ]

        # lazily assign to avoid $q <-> $timeout circular dependency
        $timeout = undefined

        decorate = (obj, key, fn) ->
          oldFn = obj[key]
          obj[key] = (args...) -> fn(oldFn, args)

        decorate $q, 'defer', (defer) ->
          deferred = defer()
          extendPromise deferred.promise
          deferred

        $q.task = (options) ->
          deferred = $q.defer()
          promise = deferred.promise
          promise.cancel = ->
            deferred.reject('cancel')
            options.cancel?()
          promise.catch (reason) -> options.cancelled?() if reason == 'cancel'
          promise.finally(-> options.destroy?())
          options.initialize?(deferred)
          promise

        extendPromise = (promise) ->
          time = Date.now()

          # re-extend derived promises
          for method in BASE_METHODS
            decorate promise, method, (m, args) -> extendPromise(m.apply(promise, args))

          angular.extend promise,

            timeout: (ms) ->
              deferred = $q.defer()
              promise.then(deferred.resolve, deferred.reject, deferred.notify)
              $timeout ?= $injector.get('$timeout')
              $timeout(deferred.reject, ms)
              deferred.promise

            progress: (callback) ->
              promise.then(null, null, callback)

            elapsed: ->
              Date.now() - time

        $q
    ]
]
