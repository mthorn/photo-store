@app = angular.module('photo-store', [ 'templates', 'ngRoute', 'ngResource', 'ngAnimate', 'ui.bootstrap', 'ngSanitize' ])

@app.constant 'config', $('script#config').data('config')

@app.config [
  "$httpProvider", "config",
  ($httpProvider,   config) ->
    $httpProvider.interceptors.push 'staleSessionDetector'
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = config.csrfParams['authenticity_token']
]

@app.config [
  '$locationProvider', '$routeProvider',
  ($locationProvider,   $routeProvider) ->

    $locationProvider.html5Mode
      enabled: true
      requireBase: false

    $routeProvider.when '/',
      redirectTo: '/gallery'

    $routeProvider.when '/gallery',
      templateUrl: 'gallery.html'
      controller: 'GalleryCtrl as ctrl'
      reloadOnSearch: false
]
