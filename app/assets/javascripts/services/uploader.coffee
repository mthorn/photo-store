@app.factory 'uploader', [
  '$rootScope', '$window', '$uibModal', '$http', 'schedule', 'Upload', 'Library',
  ($rootScope,   $window,   $uibModal,   $http,   schedule,   Upload,   Library) ->

    RATE_WINDOW_SIZE = 30000

    startTime = rateWindow = lastTimeRemaining = lastTimeRemainingCalculatedAt = undefined

    handleBeforeUnload = ->
      "Your file import will be incomplete if you leave this page. You can " +
      "resume the import later by dropping the same set of files on the page, " +
      "already completed files will not be duplicated."

    enqueue = (files, where = 'end', importDate = new Date) ->
      return if files.length == 0

      if ! svc.queue
        svc.queue = schedule.executor(1)
        svc.progress =
          count: 0  # number of files
          done: 0   # number of finished files
          total: 0  # total bytes to upload
          loaded: 0 # total uploaded bytes
        startTime = Date.now()
        svc.skipped = 0
        rateWindow = [ [ startTime, 0 ] ]
        $($window).on('beforeunload', handleBeforeUnload)

        svc.queue.whenIdle().then =>
          $($window).off('beforeunload', handleBeforeUnload)
          svc.queue = svc.progress = startTime = rateWindow = null

      libraryId = Library.current?.id
      for file in files
        do (file) =>
          svc.progress.count += 1
          svc.progress.total += file.size
          svc.queue((=>
            svc.current =
              file: file
              upload: new Upload
                modified_at: file.lastModifiedDate
                file: file
                name: file.name
                size: file.size
                mime: file.mime ? file.type
                imported_at: importDate
                library_id: libraryId
            (svc.current.promise = svc.current.upload.start()).
              then(
                (=>
                  svc.progress.done += 1
                  svc.progress.loaded += file.size
                ),
                ((reason) =>
                  if angular.equals(reason.data, name: [ 'has already been uploaded' ])
                    svc.skipped += 1
                    svc.progress.done += 1
                    svc.progress.total -= file.size
                  else
                    svc.progress.count -= 1
                    svc.progress.total -= file.size
                    if reason != 'cancel'
                      svc.errors.push(
                        file: svc.current.file
                        importDate: importDate
                        reason: reason
                      )
                ),
                ((currentProgress) =>
                  svc.current.progress = currentProgress
                  rateWindow.push([ now = Date.now(), now, svc.progress.loaded + svc.current.progress.loaded ])
                )
              ).
              finally(=>
                svc.current = null
              )
          ), where)


    angular.extend (svc = {}),
      errors: []
      checking: 0
      skipped: 0
      queue: null
      progress: null
      current: null

      import: (files) ->
        if ! Library.current['can_upload?']
          $uibModal.open(templateUrl: 'can_not_upload.html')
          return

        checks = files.map (file, i) ->
          id: i
          name: file.name
          size: file.size
          mime: file.mime ? file.type

        svc.checking += 1
        $http(
          method: 'POST'
          url: "/api/libraries/#{Library.current?.id}/uploads/check.json"
          data: { is_new: checks }
        ).then((response) =>
          newFiles = []
          for i in response.data
            newFiles.push(files[i])
          enqueue(newFiles)

          skipped = files.length - newFiles.length
          svc.skipped += skipped
          if svc.progress
            svc.progress.count += skipped
            svc.progress.done += skipped
        ).finally(=>
          svc.checking -= 1
        )

      timeRemaining: ->
        return null unless startTime
        loaded = svc.progress.loaded + (svc.current?.progress?.loaded || 0)
        return null if loaded == 0

        now = Date.now()
        return lastTimeRemaining if now - (lastTimeRemainingCalculatedAt || 0) < 1000
        lastTimeRemainingCalculatedAt = now

        elapsed = now - startTime
        expected = elapsed * svc.progress.total / loaded
        lastTimeRemaining = Math.ceil((expected - elapsed) / 1000) * 1000

      uploadRate: ->
        if rateWindow?
          # discard entries not in window
          now = Date.now()
          cutoff = now - RATE_WINDOW_SIZE
          rateWindow.shift() while rateWindow.length != 0 && rateWindow[0][0] < cutoff

          if rateWindow.length >= 2 # rate = 0 if there aren't 2 entries to compare
            first = rateWindow[0]
            last = rateWindow[rateWindow.length - 1]
            last[1] = now if now - last[1] > 1000 # return value changes max once per second after last progress update, to prevent infinite digest
            return Math.max((last[2] - first[2]) / ((last[1] - first[0]) / 1000), 0)

        0

      pause: ->
        svc.queue.pause()
        svc.current?.promise?.pause()

      unpause: ->
        svc.queue.unpause()
        svc.current?.promise?.unpause()

      cancel: ->
        svc.skipped = 0
        svc.queue.clear()
        svc.current?.promise?.abort()

      retryAll: ->
        for failure in svc.errors.reverse()
          enqueue([ failure.file ], 'start', failure.importDate)
        svc.errors.splice(0, svc.errors.length)

      viewErrors: ->
        $uibModal.open(
          templateUrl: 'errors.html'
          scope: scope = angular.extend($rootScope.$new(),
            errors: svc.errors
            retryAt: (i) ->
              if (failure = svc.errors?.splice(i, 1)[0])?
                enqueue([ failure.file ], 'start', failure.importDate)
          )
        ).result.finally(->
          scope.$destroy()
        )
]
