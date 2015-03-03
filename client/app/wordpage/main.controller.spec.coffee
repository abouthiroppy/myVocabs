'use strict'

describe 'Controller: WordpageCtrl', ->

  # load the controller's module
  beforeEach module 'myVocabsApp' 
  beforeEach module 'socketMock' 

  WordpageCtrl = undefined
  scope = undefined
  $httpBackend = undefined

  # Initialize the controller and a mock scope
  beforeEach inject (_$httpBackend_, $controller, $rootScope) ->
    $httpBackend = _$httpBackend_
    $httpBackend.expectGET('/api/things').respond [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
      'Express'
    ]
    scope = $rootScope.$new()
    WordpageCtrl = $controller 'WordpageCtrl',
      $scope: scope

  it 'should attach a list of things to the scope', ->
    $httpBackend.flush()
    expect(scope.wordData.length).toBe 4