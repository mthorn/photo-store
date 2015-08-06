@app.factory 'schedule', [
  '$q', '$timeout', '$exceptionHandler',
  ($q,   $timeout,   $exceptionHandler) ->

    noop = ->

    once = (delay = 0, fn = noop) ->
      if arguments.length == 1 && angular.isFunction(delay)
        fn = delay
        delay = 0

      $q.task
        initialize: (deferred) ->
          @timer = $timeout(fn, delay)
          @timer.then(deferred.resolve, deferred.reject)
        cancel: ->
          $timeout.cancel(@timer)

    repeatAtRate = (initial, interval, count = 0, fn = noop) ->
      if arguments.length == 3 && angular.isFunction(count)
        fn = count
        count = 0
      if arguments.length == 2 && angular.isFunction(interval)
        fn = interval
        interval = initial
      if arguments.length == 1
        interval = initial

      $q.task
        initialize: (@deferred) ->
          @tick = @tick.bind(@)
          @timer = $timeout(@tick, initial)
        destroy: ->
          $timeout.cancel(@timer) if @timer
        cancelled: ->
          @subtask?.cancel?()
        cancel: ->
          $timeout.cancel(@timer) if @timer

        i: 0

        tick: ->
          @timer = null

          @i += 1
          @deferred.notify(@i)

          try
            @subtask = fn(@deferred.resolve)
          catch e
            @deferred.reject e
            $exceptionHandler e
            return

          if @i == count
            @deferred.resolve()
          else
            @timer = $timeout(@tick, interval)

    repeatWithDelay = (initial, interval, count = 0, fn = noop) ->
      if arguments.length == 3 && angular.isFunction(count)
        fn = count
        count = 0
      if arguments.length == 2 && angular.isFunction(interval)
        fn = interval
        interval = initial
      if arguments.length == 1
        interval = initial

      $q.task
        initialize: (@deferred) ->
          @tick = @tick.bind(@)
          @timer = $timeout(@tick, initial)
        destroy: ->
          @isFinished = true
          $timeout.cancel(@timer) if @timer
        cancelled: ->
          @subtask?.cancel?()
        cancel: ->
          $timeout.cancel(@timer) if @timer

        tick: ->
          @timer = null
          count -= 1

          try
            @subtask = fn(@deferred.resolve)
          catch e
            @deferred.reject e
            $exceptionHandler e
            return

          $q.when(@subtask).then(
            ((value) =>
              return if @isFinished
              @deferred.notify(value)
              if count == 0
                @deferred.resolve()
              else
                @timer = $timeout(@tick, interval)
            ),
            @deferred.reject
          )

    executor = (concurrency = 1) ->
      queue = []
      running = 0
      emptyDeferred = null
      paused = false

      runTasks = ->
        while ! paused && running < concurrency && (task = queue.shift())
          [ fn, deferred ] = task
          running += 1
          try
            $q.when(fn()).
              finally(->
                running -= 1
                runTasks()
              ).
              then(deferred.resolve, deferred.reject)
          catch e
            $exceptionHandler(e)
            running -= 1

        if emptyDeferred && running == 0 && queue.length == 0
          emptyDeferred.resolve()
          emptyDeferred = null

      exec = (tasks) ->
        tasks = [ tasks ] if angular.isFunction tasks
        tasks = tasks.map((task) -> [ task, $q.defer() ])

        queue = queue.concat(tasks)
        $timeout runTasks

        $q.all(tasks.map(([ task, deferred ]) -> deferred.promise))

      exec.whenIdle = ->
        emptyDeferred ?= $q.defer()
        $timeout runTasks
        emptyDeferred.promise

      exec.clear = (finalizer = 'reject', valueOrReason) ->
        if queue.length
          for [ _, deferred ] in queue
            deferred[finalizer](valueOrReason)
          queue.clear()
          $timeout runTasks
        exec

      exec.pause = -> paused = exec.isPaused = true
      exec.unpause = ->
        $timeout runTasks
        paused = exec.isPaused = false

      exec

    angular.extend once,
      once: once
      delay: once
      repeatAtRate: repeatAtRate
      repeatWithDelay: repeatWithDelay
      executor: executor
]
