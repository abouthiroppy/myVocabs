'use strict'

angular.module 'myVocabsApp'
.controller 'WordpageCtrl', ($scope, $http, socket, $location, Auth) ->
  
  $scope.wordData   = []
  $scope.isLoggedIn = Auth.isLoggedIn
  noSelectTagText   = '--------------'

  # $.fn.editable.defaults.mode = 'inline'

  # icheck setting
  $('input').iCheck
    checkboxClass: 'icheckbox_flat'
    radioClass: 'iradio_flat'

  # change button
  $scope.editWord = ->
    $location.path '/' + $location.$$path.split('/')[1] + '/edit'

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

  $http.get('/api/words/' + $location.$$path.split('/')[1]).success (wordData) ->
    $('.priority-color-border').addClass wordData.priority
    $scope.wordData = wordData
    socket.syncUpdates 'word', $scope.wordData
    markdown.outputText = marked wordData.description

  selectCallback = (value, index)->
    selectTagText = $('span.selecter-selected').first().text()
    if selectTagText is noSelectTagText 
      selectTagText = '' 
    $scope.filter.tag = selectTagText
    $scope.tableParams.reload()


  $scope.deleteWord = (word) ->
    $http.delete('/api/words/' + word._id).success ->

  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'word'
