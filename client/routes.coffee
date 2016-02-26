angular.module("coffeeGang").config ($urlRouterProvider, $stateProvider, $locationProvider) ->
  $locationProvider.html5Mode true
  $stateProvider.state "memberList",
    url: "/memberList"
    template: "<member-list></member-list>"
  $stateProvider.state "member",
    url: "/members/:memberName"
    template: "<member></member>"
  $urlRouterProvider.otherwise "/memberList"
