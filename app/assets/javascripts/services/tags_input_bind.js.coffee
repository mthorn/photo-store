@app.factory 'tagsInputBind', [
  '$rootScope',
  ($rootScope) ->
    (tiModel, realModel) ->
      unwatch1 = $rootScope.$watch((=> realModel[0][realModel[1]]), ((tagStr) =>
        tiModel[0][tiModel[1]] =
          if tagStr
            tagStr.split(',').map((tag) -> { text: tag })
          else
            null
      ))

      unwatch2 = $rootScope.$watch((=> tiModel[0][tiModel[1]]), ((tagObjects) =>
        realModel[0][realModel[1]] =
          if tagObjects
            tagObjects.map((tag) -> tag.text).join(',')
          else
            null
      ), true)

      ->
        unwatch1()
        unwatch2()
]
