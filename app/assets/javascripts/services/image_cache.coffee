@app.factory 'imageCache', [
  '$q', '$window',
  ($q,   $window) ->

    SIZE = 20

    entries = []

    angular.extend (service = {}),

      store: (url) ->
        if (i = _.findIndex(entries, (e) -> e.url == url)) != -1
          entry = entries.splice(i, 1)
          entries.push(entry[0])
        else
          entry = url: url
          entry.image = new Image
          entry.image.src = url
          entry.promise = $q((resolve) -> $(entry.image).on('load', -> resolve(entry.image)))
          entries.push(entry)

        entries.shift() while entries.length > SIZE

        entry.promise

      fetch: (url) ->
        _.find(entries, url: url)?.promise || @store(url)

]
