@app.directive 'customTag', ->
  (scope, element) ->
    scope.$watch (-> scope.$getDisplayText()), (text) ->
      return unless text
      negative = text[0] == '-'
      element.closest('li.tag-item').toggleClass('negative', negative)
