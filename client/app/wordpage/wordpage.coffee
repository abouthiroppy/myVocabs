'use strict'

angular.module 'myVocabsApp'
.config ($routeProvider) ->
  $routeProvider
  .when '/:id',
    templateUrl: 'app/wordpage/wordpage.html'
    controller: 'WordpageCtrl'
