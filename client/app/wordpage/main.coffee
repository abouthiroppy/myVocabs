'use strict'

angular.module 'myVocabsApp'
.config ($routeProvider) ->
  $routeProvider
  .when '/:id',
    templateUrl: 'app/wordpage/main.html'
    controller: 'WordpageCtrl'
