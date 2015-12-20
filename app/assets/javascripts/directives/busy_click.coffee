@app.directive 'busyClick', [
  '$parse', '$q',
  ($parse,   $q) ->
    (scope, element, attrs) ->
      fn = $parse(attrs.busyClick)

      element.on 'click', (event) ->
        return if element.hasClass('btn-busy')
        element.attr('disabled', true).addClass('btn-busy')
        scope.$apply ->
          result = fn(scope, $event: event)
          $q.when(result).finally ->
            element.removeAttr('disabled').removeClass('btn-busy')
]

