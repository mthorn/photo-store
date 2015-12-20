@app = angular.module('photo-store', [ 'templates', 'ngRoute', 'ngResource', 'ngAnimate', 'ui.bootstrap', 'ngSanitize', 'ngTagsInput' ])

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
      templateUrl: 'gallery.html'
      controller: 'GalleryCtrl as ctrl'
      reloadOnSearch: false

    $routeProvider.when '/:library_id/slides',
      templateUrl: 'slides.html'
      controller: 'SlidesCtrl as ctrl'
      reloadOnSearch: false

    $routeProvider.when '/admin/libraries',
      templateUrl: 'admin/libraries.html'
      controller: 'AdminLibrariesCtrl as ctrl'
]
