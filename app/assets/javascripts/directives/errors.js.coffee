@app.directive 'errors', ->
  (scope, element, attrs) ->
    messages = $('<p/>').addClass('control-label').hide().appendTo(element)
    element.addClass 'errors'
    scope.$watch(attrs.errors, ((errors) ->
      errors = _.compact(_.flatten(errors || []))
      if errors.length
        messages.show().text(errors.join(', '))
        element.addClass('has-error')
      else
        messages.hide()
        element.removeClass('has-error')
    ), true)

