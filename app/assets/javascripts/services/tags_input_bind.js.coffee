@app.factory 'tagsInputBind', [
  '$rootScope',
  ($rootScope) ->
    (tiModel, realModel) ->
      $rootScope.$watch((=> realModel[0][realModel[1]]), ((tagStr) =>
        console.log("@view.tag_new = #{tagStr}")
        tiModel[0][tiModel[1]] =
          if tagStr
            tagStr.split(/ +/g).map((tag) -> { text: tag })
          else
            null
      ))

      $rootScope.$watch((=> tiModel[0][tiModel[1]]), ((tagObjects) =>
        console.log("@tag_new = #{JSON.stringify tagObjects}");
        realModel[0][realModel[1]] =
          if tagObjects
            tagObjects.map((tag) -> tag.text).join(' ')
          else
            null
      ), true)
]
