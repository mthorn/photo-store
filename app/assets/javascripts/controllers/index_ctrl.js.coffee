class @IndexCtrl extends Controller

  @inject '$http', '$window', '$location', '$routeParams', 'Upload',
    'schedule', 'placeholderImageUrl'

  initialize: ->
    @scope.$watch @parseSearchParams, ((@params) =>), true
    @scope.$watch (=> @params), @fetch, true
    @Upload.on('uploaded', @fetch)

  fetch: =>
    if changed = ! angular.equals(@params, @parseSearchParams())
      @location.search(@params)

    if ! changed && (@fetching || @fetchAgain)
      return @fetchAgain = true

    @timer?.cancel()
    @fetching = @http(
      method: 'GET'
      url: "/api/libraries/#{@routeParams.library_id}/uploads.json"
      params: @queryParams()
    ).then((response) =>
      @items = response.data.items.map((upload) => new @Upload(upload))
      @items.count = response.data.count

      if @fetchAgain || _.any(@items, state: 'process')
        @timer?.cancel()
        @timer = @schedule.delay(5000, @fetch)
      null
    ).catch(=>
      @timer?.cancel()
      @timer = @schedule.delay(5000, @fetch)
    ).finally(=>
      @fetching = null
      @fetchAgain = false
    )

  '$on($destroy)': =>
    @timer?.cancel()
    @Upload.off('uploaded', @fetch)
