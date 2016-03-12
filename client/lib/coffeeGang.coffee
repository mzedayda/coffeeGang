Members = null
Meteor.startup ->
  Members = share.collections?.members

Meteor.loginWithPassword "guest", "guest", (err) ->
  console.error err if err

angular.module("coffeeGang", ["angular-meteor", "ui.router"])

angular.module("coffeeGang").controller "mainCtrl", ["$scope", ($scope) ->
  $scope.username =  -> Meteor.user()?.username
  $scope.$watch "showInactive", ->
    if $scope.showInactive then $scope.query = {}
    else $scope.query = { active: $ne: false }
  $scope.adminView = -> Meteor.user()?.username is "Admin"
  $scope.submitAdmin = (password) ->
    unless password is ""
      Meteor.loginWithPassword "Admin", password, (err) ->
        console.error err if err
    return false
  $scope.logout = ->
    Meteor.loginWithPassword "guest", "guest"
    return false
  $scope.addMember = (member) ->
    return false unless $scope.adminView()
    return false unless member.name?.length > 0 and member.email?.length > 0
    Members.insert
      name: member.name
      email: member.email
      active: true
      dates: []
      createdAt: new Date()
    $("#newMemberModal").modal("hide")
    return false
  $scope.dueMember = ->
    member = Members.findOne { active: true }, sort: lastCoffee: 1
    if member? then return member.name else return "No Active Members"
  $scope.dateToString = (date) ->
    return "#{date.getDate()}/#{date.getMonth()+1}/#{date.getFullYear() % 100}"
  $scope.submitNotification = ->
    sendBtn = $("#send-notification").button("sending")
    Meteor.call "sendEmail", (err, result) ->
      if result?.statusCode is 200
        sendBtn.button("sent")
        setTimeout ->
          sendBtn.button("reset")
        , 2000
      else if result?.statusCode is 400
        sendBtn.button("reset")
        $("#alertMessage").text result.body
        alert = $(".alert").show()
        setTimeout ->
          alert.hide()
        , 3000
    return false
]