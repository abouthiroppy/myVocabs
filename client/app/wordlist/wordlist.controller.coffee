'use strict'

angular.module 'myVocabsApp'
.controller 'WordlistCtrl', ($scope, $http, ngTableParams, $filter) ->
  $scope.wordData  = []
  $scope.filter    =
    word     : ''
    priority : ''
    tag      : ''
  allTagSelectText = 'ALL'
  noTagSelectText  = '--------------'

  $scope.sort =
    #word: ''  # asc and desc
    date: 'desc'

  # icheck setting
  $('input').iCheck
    checkboxClass : 'icheckbox_flat'
    radioClass    : 'iradio_flat'

  # getting current setting
  $http.get('/api/current').success (currentSetting) ->

    # init setting
    # current selecting tag
    if currentSetting.selectTag == undefined
      currentSetting.selectTag = allTagSelectText

    # replace tag name
    # all tag
    if currentSetting.selectTag is ''
      currentSetting.selectTag = allTagSelectText
    # no tag
    if currentSetting.selectTag is '<none>'
      currentSetting.selectTag = noTagSelectText

    # getting wordlist
    fetchWordList currentSetting.selectTag

    # getting tags
    $http.get('/api/tags').success (tagData) ->
      $scope.tagData = []
      $scope.tagData.push
        name  : noTagSelectText
        value : noTagSelectText
      $scope.tagData = $scope.tagData.concat tagData

      # tag selector
      setTimeout ->
        $('.selecter').selecter
          mobile   : true
          callback : selectCallback
          label    : currentSetting.selectTag
      , 0

  # getting wordData
  ###########################################################################
  fetchWordList = (currentTag) ->
    $http.get('/api/words').success (wordData) ->
      $scope.wordData = wordData
      # calculate distribution of word priority
      priorityCount =
        low    : 0
        middle : 0
        high   : 0
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

      # socket.syncUpdates 'word', $scope.wordData
      $scope.tableParams = new ngTableParams(
        page    : 1
        count   : 10
        filter  : $scope.filter
        sorting : $scope.sort
      ,
        total   : wordData.length
        getData : ($defer, params) ->
          filteredData = params.filter() && $filter('filter')(wordData, params.filter()) || wordData
          orderedData  = params.sorting() && $filter('orderBy')(filteredData, params.orderBy()) || wordData;
          $scope.users = orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count())
          params.total orderedData.length
          $defer.resolve $scope.users
      )
  ###########################################################################

  selectCallback = (value, index) ->
    selectTagText = $('span.selecter-selected').first().text()
    # all tag
    if selectTagText is allTagSelectText
      selectTagText = ''
    # no tag
    if selectTagText is noTagSelectText
      selectTagText = '<none>'
    $scope.filter.tag = selectTagText
    $scope.tableParams.reload()

    # push current tag to server
    $http.post '/api/current',
      selectTag: $scope.filter.tag
    .success (json) ->

  # keyboard shortcut
  ########################################################
  # open and close tag-selecter
  Mousetrap.bind 'ctrl+k', () ->
    $('.selecter-selected').click()
    Mousetrap.bind 'up', () ->
      $('.selecter-item[data-value=1]').focus()

  # focus to search-bar
  Mousetrap.bindGlobal 'ctrl+f', () ->
    if $('#word-find').is(':focus')
      $('#word-find').blur()
    else
      $('#word-find').focus()

  # clear of search-bar text
  Mousetrap.bindGlobal 'ctrl+c', () ->
    $('#word-find').val('')
    $scope.filter.word = ''
    $scope.tableParams.reload()

  Mousetrap.bind 'j', () ->
    console.log('aaa')
  , 'down'
  ########################################################

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
    $scope.tableParams.reload()

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

  $scope.deleteWord = (word) ->
    $http.delete('/api/words/' + word._id).success ->
      setTimeout ->
        $scope.tableParams.reload()
      , 0
