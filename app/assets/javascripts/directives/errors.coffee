@app.directive 'errors', ->
  (scope, element, attrs) ->
    row = element.closest('.form-group')
    messages = $('<p/>').addClass('help-block').hide().appendTo(element)
    scope.$watch(attrs.errors, ((errors) ->
      errors = _.compact(_.flatten(errors || []))
      if errors.length
        messages.show().text(errors.join(', '))
        row.addClass('has-error')
      else
        messages.hide()
        row.removeClass('has-error')
    ), true)

