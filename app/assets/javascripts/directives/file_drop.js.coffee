@app.directive 'fileDrop', [
  '$parse', '$log', '$window', '$q', '$rootScope', 'config',
  ($parse,   $log,   $window,   $q,   $rootScope,   config) ->
    TYPES =
      image: [ 'image/gif', 'image/jpeg', 'image/png' ]
      video: [ 'video/mp4', 'video/webm', 'video/x-m4v', 'video/ogg' ]
      doc: [ 'application/pdf' ]
    HINTS =
      image: [ 'JPG', 'PNG', 'GIF' ]
      video: [ 'MP4', 'WebM' ]
      doc: [ 'PDF' ]

    HOST_BLACKLIST = _.compact([
      $window.location.host,
      config.s3Host,
      'cdn.omnistre.am'
    ]).map((h) -> h.replace(/\./g, '\\.'))
    HOST_BLACKLIST_RE = new RegExp("^https?://(?:#{HOST_BLACKLIST.join('|')})/")

    {
      link: (scope, element, attrs, controller) ->
        callback = $parse attrs.fileDrop

        types = []
        hints = []
        if attrs.dropTypes
          for type in attrs.dropTypes.split(',')
            types = types.concat(TYPES[type])
            hints = hints.concat(HINTS[type])
        else
          for k, v of TYPES
            types = types.concat(v)
          for k, v of HINTS
            hints = hints.concat(v)

        element.addClass 'drop-target'

        handleDragOver = (e) ->
          element.addClass 'active'
          false

        handleDragLeave = (e) ->
          element.removeClass 'active'

        handleDrop = (e) ->
          element.removeClass 'active'
          $rootScope.$apply ->
            getTransferFiles(e.originalEvent.dataTransfer).then((filesOrUrl) ->
              valid = filesOrUrl.filter (f) -> f.type in types
              if valid.length
                $log.debug "Dropped file types: #{valid.map((f) -> f.type).join(', ')}"
                callback(scope, files: valid, file: valid[0], url: null)
            )
          false

        getTransferFiles = (transfer, done) ->
          $q.all(
            _.map(transfer.items, (item) ->
              getFiles(item.webkitGetAsEntry())
            )
          ).then((files) =>
            _.compact(_.flatten(files))
          )

        getFiles = (entry) ->
          if entry.isDirectory
            $q((resolve, reject) ->
              entry.createReader().readEntries((entries) ->
                $rootScope.$apply ->
                  $q.all(entries.map(getFiles)).
                    then(_.flatten).
                    then(resolve)
              )
            )
          else if entry.isFile
            $q((resolve, reject) ->
              entry.file (file) -> $rootScope.$apply -> resolve(file)
            )
          else
            null

        $('html').
          on('dragover',  handleDragOver).
          on('dragleave', handleDragLeave).
          on('drop',      handleDrop)

        scope.$on '$destroy', ->
          $('html').
            off('dragover',  handleDragOver).
            off('dragleave', handleDragLeave).
            off('drop',      handleDrop)
    }
]
