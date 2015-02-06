'use strict'

descriptionText = ''

angular.module 'myVocabsApp'
.controller 'AddwordCtrl', ($scope, $http, socket) ->
  $scope.awesomeThings = []
  $scope.newThing = ''
  $scope.roughly = ''
  $scope.priority = 0

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

  $scope.addThing = ->
    return if $scope.newThing is ''
    $http.post '/api/things',
      word: $scope.newThing
      roughly: $scope.roughly
      description: descriptionText
      priority: $scope.priority
      date: moment().format()
      accessCount: 0
      close: false

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
