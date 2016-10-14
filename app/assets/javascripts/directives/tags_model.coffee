@app.directive 'tagsModel', ->
  (scope, element, attrs) ->

    type = attrs.tagsModelType || 'string'

    scope.$watch(attrs.tagsModel, ((value) ->
      type = 'array' if angular.isArray(value)
      assignNgModel(
        if ! value
          null
        else
          (if type == 'string' then value.split(',') else value).
            filter((tag) -> tag).map((tag) -> { text: tag })
      )
    ), true)

    scope.$watch(attrs.ngModel, ((value) ->
      assignTagsModel(
        if ! value
          if type == 'string' then '' else null
        else
          tags = value.map(_.property('text'))
          if type == 'string' then tags.join(',') else tags
      )
    ), true)

    assignModel = (model, value) ->
      path = model.split('.')
      obj = _.reduce(_.initial(path), ((obj, attr) -> obj?[attr]), scope)
      obj?[_.last(path)] = value

    assignTagsModel = (value) -> assignModel(attrs.tagsModel, value)
    assignNgModel = (value) -> assignModel(attrs.ngModel, value)
