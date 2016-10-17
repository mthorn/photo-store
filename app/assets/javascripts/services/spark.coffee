@app.factory 'spark', [
  '$window', '$q', '$rootScope',
  ($window,   $q,   $rootScope) ->

    CHUNK_SIZE = 1048576

    md5file: (file) ->
      $q (resolve, reject) ->
        spark = new $window.SparkMD5.ArrayBuffer
        reader = new $window.FileReader
        chunks = Math.ceil(file.size / CHUNK_SIZE)
        i = 0

        reader.onload = ->
          spark.append(reader.result)
          i += 1
          if i < chunks
            loadNext()
          else
            $rootScope.$applyAsync ->
              file.md5sum = md5sum = spark.end()
              console.log("sum: #{md5sum}")
              resolve(md5sum)

        reader.onerror = -> $rootScope.$applyAsync -> reject()

        loadNext = ->
          start = i * CHUNK_SIZE
          end = if start + CHUNK_SIZE > file.size then file.size else start + CHUNK_SIZE
          console.log("reading chunk #{start} - #{end}")
          reader.readAsArrayBuffer(file.slice(start, end))

        loadNext()
]
