'use strict'

descriptionText = ''

angular.module 'myVocabsApp'
.controller 'AddwordCtrl', ($scope, $http, socket) ->
  $scope.newThing = ''
  $scope.roughly = ''
  $scope.priority = 'priority-low-color'

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

  # エラーでている
  $scope.$watch 'marked.inputText', (current, original) ->
    descriptionText = current
    markdown.outputText = marked current


  # priority
  $scope.changePriority = (color) ->
    $scope.priority = color
    $('.priority-group').removeClass('priority-select')
    $('#priority-low').addClass('priority-select') if color is 'priority-low-color'
    $('#priority-middle').addClass('priority-select') if color is 'priority-middle-color'
    $('#priority-high').addClass('priority-select') if color is 'priority-high-color'
    return true


  $http.get('/api/tags').success (tagData) ->
    $scope.tagData = tagData
    # tag selector
    setTimeout ->
      $('.selecter').selecter()
    , 0

  $scope.addTags = ->
    return if $scope.newTag is '' or $scope.newTag is undefined
    $http.post '/api/tags',
      name: $scope.newTag
      value: $scope.newTag
    .success (obj) ->
      $scope.newTag = ''
      alert 'add tag'
      $scope.tagData.push obj
    .error ->
      console.log 'error'

  $scope.addWord = ->
    return if $scope.newThing is ''
    $http.post '/api/things',
      word: $scope.newThing
      roughly: $scope.roughly
      description: descriptionText
      priority: $scope.priority
      date: moment().format()
      accessCount: 0
      close: false
    .success (json) ->
      $('.form-control').val('');
      $('.priority-group').removeClass('priority-select')
      $('#priority-low').addClass('priority-select')
      $scope.priority = 'priority-low-color'
      alert 'success'
    .error (json) ->
      alert 'error'

###
.directive 'autoGrow', ->
  return (scope, element, attr) ->
    varupdate = ->
      element.css 'height', 'auto'
      element.css 'height', element[0].scrollHeight + 'px'
    scope.$watch attr.ngModel, ->
      update();

    attr.$set 'ngTrim', 'false'
###
