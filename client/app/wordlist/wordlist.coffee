'use strict'

angular.module 'myVocabsApp'
.config ($routeProvider) ->
  $routeProvider
  .when '/wordlist',
    templateUrl: 'app/wordlist/wordlist.html'
    controller: 'WordlistCtrl'
	  authenticate: true
