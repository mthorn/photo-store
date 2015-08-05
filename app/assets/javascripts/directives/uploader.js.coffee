@app.directive 'uploader', [
  'schedule', 'Upload',
  (schedule,   Upload) ->

    templateUrl: 'uploader.html'

    scope: true
    controller: class extends Controller

      initialize: ->

      enqueue: (files) ->
        return if files.length == 0

        if ! @queue
          @queue = schedule.executor(1)
          @progress =
            count: 0  # number of files
            done: 0   # number of finished files
            total: 0  # total bytes to upload
            loaded: 0 # total uploaded bytes
          @startTime = Date.now()

        for file in files
          do (file) =>
            @progress.count += 1
            @progress.total += file.size
            @queue =>
              (new Upload(
                modified_at: file.lastModifiedDate
                file: file
                name: file.name
                size: file.size
                mime: file.type
              )).
                create().
                then(
                  (=>
                    @progress.done += 1
                    @progress.loaded += file.size
                  ),
                  (=>
                    @progress.count -= 1
                    @progress.total -= file.size
                  ),
                  ((@fileProgress) =>)
                ).
                finally(=>
                  @fileProgress = null
                )

        if @progress.count == files.length
          @queue.whenIdle().then =>
            @queue = @progress = @startTime = null


      timeRemaining: ->
        return null unless @startTime
        elapsed = Date.now() - @startTime
        expected = elapsed * @progress.total / (@progress.loaded + (@fileProgress?.loaded || 0))
        Math.round(expected - elapsed)

    controllerAs: 'ctrl'
    link: (scope, element, attrs) ->


]
