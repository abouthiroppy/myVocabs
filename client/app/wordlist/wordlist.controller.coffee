'use strict'

angular.module 'myVocabsApp'
.controller 'WordlistCtrl', ($scope, $http, socket, ngTableParams, $filter) ->
  $scope.wordData  = []
  $scope.filter    = 
    word: ''
    priority: ''
    tag: ''

  $scope.sort      = 
    #word: ''  # asc and desc
    date: 'desc'

  allTagSelectText = 'ALL'
  noSelectTagText  = '--------------'


  # icheck setting
  $('input').iCheck
    checkboxClass: 'icheckbox_flat'
    radioClass: 'iradio_flat'

  # getting tags
  $http.get('/api/tags').success (tagData) ->
    $scope.tagData = []
    $scope.tagData.push 
      name : noSelectTagText
      value: noSelectTagText
    $scope.tagData = $scope.tagData.concat tagData
    # tag selector
    setTimeout ->
      $('.selecter').selecter
        mobile: true
        callback: selectCallback
    , 0

  selectCallback = (value, index)->
    selectTagText = $('span.selecter-selected').first().text()
    # all tag
    if selectTagText is allTagSelectText 
      selectTagText = '' 
    # no tag
    if selectTagText is noSelectTagText
      selectTagText = 'none'
    $scope.filter.tag = selectTagText
    $scope.tableParams.reload()

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
    $('#priority-none').addClass('priority-select')   if priorityClass is 'priority-none-color'
    $('#priority-low').addClass('priority-select')    if priorityClass is 'priority-low-color'
    $('#priority-middle').addClass('priority-select') if priorityClass is 'priority-middle-color'
    $('#priority-high').addClass('priority-select')   if priorityClass is 'priority-high-color'
    return true

  # getting wordData
  $http.get('/api/words').success (wordData) ->
    $scope.wordData = wordData
    # calculate distribution of word priority
    priorityCount = 
      'low'   :0
      'middle':0
      'high'  :0
    for word in wordData
      priorityCount['low']++    if word.priority is 'priority-low-color'
      priorityCount['middle']++ if word.priority is 'priority-middle-color'
      priorityCount['high']++   if word.priority is 'priority-high-color'
    if wordData.length isnt 0
      setTimeout () ->
        $('.progress-bar-success').css('width', (priorityCount['low'] / wordData.length) * 100 + '%')
        $('.progress-bar-warning').css('width', (priorityCount['middle'] / wordData.length) * 100 + '%')
        $('.progress-bar-danger').css('width', (priorityCount['high'] / wordData.length) * 100 + '%')
      , 100

    socket.syncUpdates 'word', $scope.wordData
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

  $scope.deleteWord = (word) ->
    $http.delete('/api/words/' + word._id).success ->
      setTimeout ->
        $scope.tableParams.reload()
      , 0

  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'word'
