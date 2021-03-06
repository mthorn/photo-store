@app.directive 'fileDrop', [
  '$parse', '$log', '$window', '$q', '$rootScope', 'config',
  ($parse,   $log,   $window,   $q,   $rootScope,   config) ->
    TYPES =
      image: [ 'image/gif', 'image/jpeg', 'image/png' ]
      video: [ 'video/mp4', 'video/webm', 'video/x-m4v', 'video/ogg' ]
    EXTENSIONS =
      mov: 'video/quicktime'
      mp4: 'video/mp4'
      m4v: 'video/x-m4v'

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
      fromPage = false

      handleDragStart = ->
        fromPage = true

      handleDragEnd = ->
        fromPage = false

      handleDragOver = (e) ->
        return if fromPage
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
          $rootScope.$applyAsync -> callback(scope, files: batch)

      getFilesFromEntry = (entry) ->
        waiting += 1
        if entry?.isDirectory
          readDir(entry.createReader())
        else if entry?.isFile
          entry.file (file) ->
            if file.type in types
              file.mime = file.type
              queue.push(file)
            else if file.type == '' && (ext = _.last(file.name.split('.'))) && (type = EXTENSIONS[ext.toLowerCase()])
              file.mime = type
              queue.push(file)

            decrementWaiting()
        else
          decrementWaiting()

      readDir = (reader) ->
        reader.readEntries(
          ((entries) ->
            if entries.length == 0
              decrementWaiting()
            else
              for entry in entries
                getFilesFromEntry(entry)
              readDir(reader)
          ),
          decrementWaiting
        )

      $('html').
        on('dragstart', handleDragStart).
        on('dragend',   handleDragEnd).
        on('dragover',  handleDragOver).
        on('dragleave', handleDragLeave).
        on('drop',      handleDrop)

      scope.$on '$destroy', ->
        $('html').
          off('dragstart', handleDragStart).
          off('dragend',   handleDragEnd).
          off('dragover',  handleDragOver).
          off('dragleave', handleDragLeave).
          off('drop',      handleDrop)
]
