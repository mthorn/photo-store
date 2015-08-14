@app.directive 'fileDrop', [
  '$parse', '$log', '$window', '$q', '$rootScope', 'config',
  ($parse,   $log,   $window,   $q,   $rootScope,   config) ->
    TYPES =
      image: [ 'image/gif', 'image/jpeg', 'image/png' ]
      video: [ 'video/mp4', 'video/webm', 'video/x-m4v', 'video/ogg' ]

    HOST_BLACKLIST = _.compact([
      $window.location.host,
      config.s3Host,
      'cdn.omnistre.am'
    ]).map((h) -> h.replace(/\./g, '\\.'))
    HOST_BLACKLIST_RE = new RegExp("^https?://(?:#{HOST_BLACKLIST.join('|')})/")

    BATCH_SIZE = 500

    (scope, element, attrs) ->
      callback = $parse attrs.fileDrop

      types = _.flatten(_.values(TYPES))

      handleDragOver = (e) ->
        element.addClass 'hover'
        element.removeClass 'reading'
        false

      handleDragLeave = (e) ->
        element.removeClass 'hover reading'

      handleDrop = (e) ->
        element.removeClass 'hover'
        element.addClass 'reading'

        for item in e.originalEvent.dataTransfer.items
          getFilesFromEntry(item.webkitGetAsEntry())

        false

      queue = []
      waiting = 0
      decrementWaiting = ->
        waiting -= 1
        element.removeClass('reading') if waiting == 0
        if queue.length >= BATCH_SIZE || (waiting == 0 && queue.length > 0)
          batch = queue.splice(0, queue.length)
          $log.debug "Dropped #{batch.length} files"
          $rootScope.$apply -> callback(scope, files: batch)

      getFilesFromEntry = (entry) ->
        waiting += 1
        if entry.isDirectory
          entry.createReader().readEntries (entries) ->
            for entry in entries
              getFilesFromEntry(entry)
            decrementWaiting()
        else if entry.isFile
          entry.file (file) ->
            queue.push(file) if file.type in types
            decrementWaiting()
        else
          decrementWaiting()

      $('html').
        on('dragover',  handleDragOver).
        on('dragleave', handleDragLeave).
        on('drop',      handleDrop)

      scope.$on '$destroy', ->
        $('html').
          off('dragover',  handleDragOver).
          off('dragleave', handleDragLeave).
          off('drop',      handleDrop)
]
