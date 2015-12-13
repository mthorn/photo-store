@app.directive 'uploader', ->
  templateUrl: 'footer.html'
  scope: true
  controller: [
    '$scope', 'uploader',
    ($scope,   uploader) ->
      $scope.uploader = uploader
  ]
