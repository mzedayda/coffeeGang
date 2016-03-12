Members = null
Meteor.startup ->
  Members = share.collections?.members

angular.module("coffeeGang").directive "memberList", ->
  restrict: "E"
  templateUrl: "client/memberList/memberList.html"
  controllerAs: "memberListCtrl"
  controller: ["$scope", ($scope) ->
    $scope.helpers
      members: -> Members.find($scope.getReactively("query"), { sort: lastCoffee: 1 })
    $scope.lastCoffeeDate = (member) ->
      if member.lastCoffee? then return $scope.dateToString member.lastCoffee else return ""
    $scope.lastCoffeeDaysSince = (member) ->
      return "∞" unless member.lastCoffee?
      Math.round (new Date() - member.lastCoffee) / 1000 / 60 / 60 / 24
    $scope.toggleActive = (member, event) ->
      event.stopPropagation()
      event.preventDefault()
      return false unless $scope.adminView()
      Members.update member._id, $set: active: !member.active
      return false
    $scope.delete = (member, event) ->
      event.stopPropagation()
      event.preventDefault()
      return false unless $scope.adminView()
      Members.remove member._id
      return false
    $scope.coffee = (member, event) ->
      event.stopPropagation()
      event.preventDefault()
      return false unless $scope.adminView()
      date = new Date()
      Members.update member._id, {$push: {dates: date}, $set: {lastCoffee: date}}
      return false ]