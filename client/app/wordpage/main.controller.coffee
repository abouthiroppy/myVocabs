'use strict'

angular.module 'myVocabsApp'
.controller 'WordpageCtrl', ($scope, $http, socket, $location) ->
  $scope.wordData = []

  noSelectTagText = '--------------'

  # $.fn.editable.defaults.mode = 'inline'

  ###
  $('#username').editable
    type: 'text'
    #pk   : 1
    url   : '/post'
  ###

  # icheck setting
  $('input').iCheck
    checkboxClass: 'icheckbox_flat'
    radioClass: 'iradio_flat'

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

  ###  
  $scope.$watch 'marked.inputText', (current, original) ->
    descriptionText = current
    markdown.outputText = marked current
  ###

  $http.get('/api/things/' + $location.$$path.split('/')[1]).success (wordData) ->
    console.log wordData
    $('.priority-color-border').addClass wordData.priority
    $scope.wordData = wordData
    socket.syncUpdates 'thing', $scope.wordData
    markdown.outputText = marked wordData.description
  ###
  $http.post('/api/tags').success (tagData) ->
    $scope.tagData = tagData
    # tag selector
    setTimeout ->
      $('.selecter').selecter
        mobile: true
        callback: selectCallback
    , 0
  ###

  selectCallback = (value, index)->
    selectTagText = $('span.selecter-selected').first().text()
    if selectTagText is noSelectTagText 
      selectTagText = '' 
    $scope.filter.tag = selectTagText
    $scope.tableParams.reload()


  $scope.deleteWord = (thing) ->
    $http.delete('/api/things/' + thing._id).success ->

  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'thing'
