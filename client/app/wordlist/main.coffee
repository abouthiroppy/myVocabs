'use strict'

angular.module 'myVocabsApp'
.config ($routeProvider) ->
  $routeProvider
  .when '/wordlist',
    templateUrl: 'app/wordlist/main.html'
    controller: 'WordlistCtrl'
