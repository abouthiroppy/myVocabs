'use strict'

angular.module 'myVocabsApp'
.controller 'WordpageCtrl', ($scope, $http, socket, $location, Auth) ->
  
  wordId            = $location.$$path.split('/')[1] 
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
    $location.path '/' + wordId + '/edit'

  # markdown
  markdown = this
  this.inputText = ''
  marked.setOptions
    renderer: new marked.Renderer(),
    gfm         : true
    tables      : true
    breaks      : false
    pedantic    : false
    sanitize    : false
    smartLists  : true
    smartypants : false
    highlight   : (code, lang) ->
      if lang
        return hljs.highlight(lang, code).value
      else
        return hljs.highlightAuto(code).value

  $http.get('/api/words/' + wordId).success (wordData) ->
    $('.priority-color-border').addClass wordData.priority
    $scope.wordData = wordData
    socket.syncUpdates 'word', $scope.wordData
    markdown.outputText = marked wordData.description
    if wordData.description is ''
      $('#description-content').css 'display','none'

  selectCallback = (value, index)->
    selectTagText = $('span.selecter-selected').first().text()
    if selectTagText is noSelectTagText 
      selectTagText = '' 
    $scope.filter.tag = selectTagText
    $scope.tableParams.reload()


  $scope.deleteWord = () ->
    if confirm 'Are you sure?'
      $http.delete('/api/words/' + wordId).success ->
        $location.path '/wordlist'
        
  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'word'
