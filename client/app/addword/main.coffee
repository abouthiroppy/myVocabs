'use strict'

angular.module 'myVocabsApp'
.config ($routeProvider) ->
  $routeProvider
  .when '/addword',
    templateUrl: 'app/addword/main.html'
    controller: 'AddwordCtrl'
