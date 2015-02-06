'use strict'

angular.module 'myVocabsApp'
.controller 'WordlistCtrl', ($scope, $http, socket) ->
  $scope.awesomeThings = []

  $http.get('/api/things').success (awesomeThings) ->
    console.table awesomeThings
    $scope.awesomeThings = awesomeThings
    socket.syncUpdates 'thing', $scope.awesomeThings

  $scope.addThing = ->
    return if $scope.newThing is ''
    $http.post '/api/things',
      word: $scope.newThing
      roughly: $scope.roughly
      priority: $scope.priority
      date: moment().format()
      accessCount: 0
      close: false

    $scope.newThing = ''
    $scope.roughly = ''
    $scope.priority = 0

  $scope.deleteThing = (thing) ->
    $http.delete '/api/things/' + thing._id

  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'thing'
