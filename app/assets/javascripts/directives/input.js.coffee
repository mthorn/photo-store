@app.directive 'input', ->
  require: 'ngModel'
  link: (scope, element, attrs, ngModel) ->
    # disable angular built in validation
    ngModel.$validators[attrs.type] = -> true
