'use strict'

angular.module 'myVocabsApp'
.config ($routeProvider) ->
  $routeProvider
  .when '/:id/edit',
    templateUrl: 'app/edit/edit.html'
    controller: 'EditWordCtrl'
