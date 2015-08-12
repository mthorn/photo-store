@app.directive 'uploader', [
  '$window', '$modal', 'schedule', 'Upload',
  ($window,   $modal,   schedule,   Upload) ->

    RATE_WINDOW_SIZE = 30000

    templateUrl: 'footer.html'

    scope: true
    controller: class extends Controller

      initialize: ->
        @expanded = false
        @errors = []

      handleBeforeUnload: ->
        "Your file import will be incomplete if you leave this page. You can " +
        "resume the import later by dropping the same set of files on the page, " +
        "already completed files will not be duplicated."

      enqueue: (files, where = 'end', importDate = new Date) ->
        return if files.length == 0

        if ! @queue
          @queue = schedule.executor(1)
          @progress =
            count: 0  # number of files
            done: 0   # number of finished files
            total: 0  # total bytes to upload
            loaded: 0 # total uploaded bytes
          @startTime = Date.now()
          @skipped = 0
          @rateWindow = [ [ @startTime, 0 ] ]
          $($window).on('beforeunload', @handleBeforeUnload)

        for file in files
          do (file) =>
            @progress.count += 1
            @progress.total += file.size
            @queue((=>
              @current =
                file: file
                upload: new Upload
                  modified_at: file.lastModifiedDate
                  file: file
                  name: file.name
                  size: file.size
                  mime: file.type
                  imported_at: importDate
              (@current.promise = @current.upload.create()).
                then(
                  (=>
                    @progress.done += 1
                    @progress.loaded += file.size
                  ),
                  ((reason) =>
                    if angular.equals(reason.data, name: [ 'has already been uploaded' ])
                      @skipped += 1
                      @progress.done += 1
                      @progress.total -= file.size
                    else
                      @progress.count -= 1
                      @progress.total -= file.size
                      if reason != 'cancel'
                        @errors.push(
                          file: @current.file
                          importDate: importDate
                          reason: reason
                        )
                  ),
                  ((currentProgress) =>
                    @current.progress = currentProgress
                    @rateWindow.push([ Date.now(), @progress.loaded + @current.progress.loaded ])
                  )
                ).
                finally(=>
                  @current = null
                )
            ), where)

        if @progress.count == files.length
          @queue.whenIdle().then =>
            $($window).off('beforeunload', @handleBeforeUnload)
            @queue = @progress = @startTime = @rateWindow = null

      timeRemaining: ->
        return null unless @startTime
        loaded = @progress.loaded + (@current?.progress?.loaded || 0)
        return null if loaded == 0

        now = Date.now()
        return @lastTimeRemaining if now - (@lastTimeRemainingCalculatedAt || 0) < 1000
        @lastTimeRemainingCalculatedAt = now

        elapsed = now - @startTime
        expected = elapsed * @progress.total / loaded
        @lastTimeRemaining = Math.ceil((expected - elapsed) / 1000) * 1000

      uploadRate: ->
        if @rateWindow?
          # discard entries not in window
          now = Date.now()
          cutoff = now - RATE_WINDOW_SIZE
          @rateWindow.shift() while @rateWindow[0][0] < cutoff

          if @rateWindow.length >= 2 # rate = 0 if there aren't 2 entries to compare
            first = @rateWindow[0]
            last = @rateWindow[@rateWindow.length - 1]
            return (last[1] - first[1]) / ((now - first[0]) / 1000)

        0

      pause: ->
        @queue.pause()
        # cancel current file and requeue
        @current?.promise?.abort()
        @enqueue([ @current.file ], 'start', @current.upload['imported_at']) if @current?.file?

      unpause: ->
        @queue.unpause()

      cancel: ->
        @queue.clear()
        @current?.promise?.abort()

      retryAll: ->
        for failure in @errors.reverse()
          @enqueue([ failure.file ], 'start', failure.importDate)
        @errors.splice(0, @errors.length)

      retryAt: (i) =>
        if (failure = @errors?.splice(i, 1)[0])?
          @enqueue([ failure.file ], 'start', failure.importDate)

      viewErrors: ->
        $modal.open
          templateUrl: 'errors.html'
          scope: angular.extend @scope.$new(),
            errors: @errors
            retryAt: @retryAt

    controllerAs: 'ctrl'
]
