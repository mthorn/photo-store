@app.directive 'uploader', [
  '$window', 'schedule', 'Upload',
  ($window,   schedule,   Upload) ->

    RATE_WINDOW_SIZE = 30000

    templateUrl: 'footer.html'

    scope: true
    controller: class extends Controller

      initialize: ->
        @expanded = false

      handleBeforeUnload: ->
        "Your file import will be incomplete if you leave this page. You can " +
        "resume the import later by dropping the same set of files on the page, " +
        "already completed files will not be duplicated."

      enqueue: (files) ->
        return if files.length == 0

        importDate = new Date

        if ! @queue
          @queue = schedule.executor(1)
          @progress =
            count: 0  # number of files
            done: 0   # number of finished files
            total: 0  # total bytes to upload
            loaded: 0 # total uploaded bytes
          @startTime = Date.now()
          @failed ?= 0
          @skipped = 0
          @rateWindow = [ [ @startTime, 0 ] ]
          $($window).on('beforeunload', @handleBeforeUnload)

        for file in files
          do (file) =>
            @progress.count += 1
            @progress.total += file.size
            @queue =>
              upload = new Upload(
                modified_at: file.lastModifiedDate
                file: file
                name: file.name
                size: file.size
                mime: file.type
                imported_at: importDate
              )
              (@current = upload.create()).
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
                    else if reason != 'cancel'
                      @failed += 1
                      @progress.count -= 1
                      @progress.total -= file.size
                  ),
                  ((@fileProgress) =>
                    now = Date.now()
                    @rateWindow.push([ now, @progress.loaded + @fileProgress.loaded ])
                    cutoff = now - RATE_WINDOW_SIZE
                    @rateWindow.shift() while @rateWindow[0][0] < cutoff
                  )
                ).
                finally(=>
                  @fileProgress = @current = null
                )

        if @progress.count == files.length
          @queue.whenIdle().then =>
            $($window).off('beforeunload', @handleBeforeUnload)
            @queue = @progress = @startTime = @rateWindow = null

      timeRemaining: ->
        return null unless @startTime
        loaded = @progress.loaded + (@fileProgress?.loaded || 0)
        return null if loaded == 0
        elapsed = Date.now() - @startTime
        expected = elapsed * @progress.total / loaded
        Math.ceil((expected - elapsed) / 1000) * 1000

      uploadRate: ->
        if @rateWindow? && @rateWindow.length >= 2
          first = @rateWindow[0]
          last = @rateWindow[@rateWindow.length - 1]
          (last[1] - first[1]) / ((last[0] - first[0]) / 1000)
        else
          0

      cancel: ->
        @queue.clear()
        @current?.abort()

    controllerAs: 'ctrl'
    link: (scope, element, attrs) ->


]
