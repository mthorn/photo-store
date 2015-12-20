@app.factory 'formData', [
  '$window',
  ($window) ->

    class Builder

      constructor: ->
        @data = new $window.FormData

      add: (key, val, fileName) ->
        if angular.isObject key
          attrs = key
          fileName = val
          for key, val of attrs
            if attrs.hasOwnProperty(key) && key[0] != '$' && ! angular.isFunction(val)
              if val instanceof Blob && fileName
                @data.append key, val, fileName
              else
                @data.append key, val
        else if angular.isString(key) && angular.isDefined(val)
          if fileName
            @data.append key, val, fileName
          else
            @data.append key, val

        @

      build: (key, val, fileName) ->
        @add(key, val, fileName) if key
        @data

    service = -> new Builder()
    service.build = (key, val, fileName) ->
      return key if key instanceof $window.FormData
      new Builder().build(key, val, fileName)
    service
]
