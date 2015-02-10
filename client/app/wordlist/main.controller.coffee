'use strict'

angular.module 'myVocabsApp'
.controller 'WordlistCtrl', ($scope, $http, socket, ngTableParams, $filter) ->
  $scope.wordData = []
  $scope.filter = 
    word: ''
    priority: ''
  $scope.sort = 
    #word: ''  # asc and desc
    date: 'desc'

  # icheck setting
  $('input').iCheck
    checkboxClass: 'icheckbox_flat'
    radioClass: 'iradio_flat'
  
  # tag selector
  $('.selecter').selecter()

  # sort function when select radio button of icheck
  $('input').on 'ifChanged', (e) ->
    if e.target.attributes[0].nodeValue is 'sort-new'
      delete $scope.sort.word if delete $scope.sort.word is undefined
      $scope.sort.date = 'desc'
    if e.target.attributes[0].nodeValue is 'sort-old'
      delete $scope.sort.word if delete $scope.sort.word is undefined
      $scope.sort.date = 'asc'
    if e.target.attributes[0].nodeValue is 'sort-ascending'
      delete $scope.sort.date if delete $scope.sort.date is undefined
      $scope.sort.word = 'asc' 
    if e.target.attributes[0].nodeValue is 'sort-descending'
      delete $scope.sort.date if delete $scope.sort.date is undefined
      $scope.sort.word = 'desc'
    $scope.tableParams.reload();

  # select priority for finding
  $scope.findPriority = (priorityClass) ->
    if priorityClass is 'priority-none-color'
      $scope.filter.priority = '' 
    else
      $scope.filter.priority = priorityClass

    $('.priority-group').removeClass('priority-select')
    $('#priority-none').addClass('priority-select') if priorityClass is 'priority-none-color'
    $('#priority-low').addClass('priority-select') if priorityClass is 'priority-low-color'
    $('#priority-middle').addClass('priority-select') if priorityClass is 'priority-middle-color'
    $('#priority-high').addClass('priority-select') if priorityClass is 'priority-high-color'
    return true

  $http.get('/api/things').success (wordData) ->
    $scope.wordData = wordData
    socket.syncUpdates 'thing', $scope.wordData
    $scope.tableParams = new ngTableParams(
      page: 1
      count: 10
      filter: $scope.filter
      sorting: $scope.sort
    ,
      total: wordData.length
      getData: ($defer, params) ->
        filteredData = params.filter() && $filter('filter')(wordData, params.filter()) || wordData
        orderedData  = params.sorting() && $filter('orderBy')(filteredData, params.orderBy()) || wordData;
        $scope.users = orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count())
        params.total orderedData.length
        $defer.resolve $scope.users 
    )

  $scope.deleteWord = (thing) ->
    $http.delete('/api/things/' + thing._id).success ->
      setTimeout ->
        $scope.tableParams.reload()
      , 0

  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'thing'
