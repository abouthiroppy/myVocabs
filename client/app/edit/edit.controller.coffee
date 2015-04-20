'use strict'

descriptionText = ''
selectTag = ''

angular.module 'myVocabsApp'
.controller 'EditWordCtrl', ($scope, $http, socket, $location) ->
  $scope.editWord = ''
  $scope.newTag = ''
  $scope.roughly = ''

  wordId = $location.$$path.split('/')[1]
  noSelectTagText = '--------------'

  # markdown
  markdown = this
  this.inputText = ''
  marked.setOptions
    renderer: new marked.Renderer(),
    gfm: true,
    tables: true,
    breaks: false,
    pedantic: false,
    sanitize: false,
    smartLists: true,
    smartypants: false,
    highlight: (code, lang) ->
      if lang
        return hljs.highlight(lang, code).value
      else
        return hljs.highlightAuto(code).value

  $scope.$watch 'marked.inputText', (current, original) ->
    descriptionText = current
    markdown.outputText = marked current

  # get word data
  $http.get('/api/words/' + wordId).success (wordData) ->
    $scope.editWord = wordData.word
    $scope.roughly = wordData.roughly
    $scope.marked.inputText = wordData.description
    $scope.changePriority wordData.priority

  # get tag data
  $http.get('/api/tags').success (tagData) ->
    $scope.tagData = tagData
    # tag selector
    setTimeout ->
      $('.selecter').selecter
        mobile: true
        callback: selectCallback
    , 0

  # priority
  $scope.changePriority = (color) ->
    $scope.priority = color
    $('.priority-group').removeClass('priority-select')
    $('#priority-low').addClass('priority-select') if color is 'priority-low-color'
    $('#priority-middle').addClass('priority-select') if color is 'priority-middle-color'
    $('#priority-high').addClass('priority-select') if color is 'priority-high-color'
    return true

  selectCallback = (value, index)->
    selectTagText = $('span.selecter-selected').first().text()
    if selectTagText is noSelectTagText 
      selectTag = '' 
    else
      selectTag = selectTagText

  $scope.changeWord = ->
    return if $scope.editWord is ''
    $http.put '/api/words/'+ wordId,
      word: $scope.editWord
      roughly: $scope.roughly
      description: descriptionText
      priority: $scope.priority
      date: moment().format().split('T')[0] + ' ' + moment().format().split('T')[1].split('+')[0]
      accessCount: 0
      close: false
      tag: selectTag
    .success (json) ->
      $location.path('/' + wordId)
    .error (json) ->
      alert 'error'