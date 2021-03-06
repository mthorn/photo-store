@app = angular.module('photo-store', [
  'templates', 'ngRoute', 'ngResource', 'ngAnimate', 'ui.bootstrap',
  'ngSanitize', 'ngTouch', 'ngTagsInput'
])

@app.constant 'config', $('script#config').data('config')

@app.config [
  "$httpProvider", "config",
  ($httpProvider,   config) ->
    $httpProvider.interceptors.push 'staleSessionDetector'
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = config.csrfParams['authenticity_token']
]

@app.config [
  '$locationProvider', '$routeProvider', 'config',
  ($locationProvider,   $routeProvider,   config) ->

    $locationProvider.html5Mode
      enabled: true
      requireBase: false

    $routeProvider.when '/',
      redirectTo: "/#{config.user.default_library_id}/gallery"

    $routeProvider.when '/:library_id/gallery',
      template: '<ps-gallery/>'
      reloadOnSearch: false

    $routeProvider.when '/:library_id/slides',
      template: '<ps-slideshow/>'
      reloadOnSearch: false

    $routeProvider.when '/admin/libraries',
      template: '<ps-admin-libraries/>'
]
