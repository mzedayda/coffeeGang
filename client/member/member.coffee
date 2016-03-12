Members = null
Meteor.startup ->
  Members = share.collections?.members

angular.module("coffeeGang").directive "member", ->
  restrict: "E"
  templateUrl: "client/member/member.html"
  controllerAs: "memberCtrl"
  controller: ["$scope", "$stateParams", ($scope, $stateParams) ->
    $scope.member = Members.findOne { name: $stateParams.memberName }
    $scope.lastCoffeeDaysSince = ->
      return "∞" unless $scope.member.lastCoffee?
      Math.round (new Date() - $scope.member.lastCoffee) / 1000 / 60 / 60 / 24 ]
