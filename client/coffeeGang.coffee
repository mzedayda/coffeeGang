Members = null
Meteor.startup ->
  Members = share.collections?.members

Meteor.loginWithPassword "guest", "guest", (err) ->
  console.error err if err

adminView = ->
  Meteor.user()?.username is 'Admin'
dateToString = (date) ->
  return "#{date.getDate()}/#{date.getMonth()+1}/#{date.getFullYear() % 100}"

Template.mainLayout.helpers
  members: ->
    if Session.get('showInactive')
      return Members.find {}, sort: lastCoffee: 1
    else
      return Members.find { active: true }, sort: lastCoffee: 1
  dueMember: ->
    member = Members.findOne { active: true }, sort: lastCoffee: 1
    if member? then return member.name else return "No Active Members"
  showInactive: ->
    Session.get 'showInactive'
  username: ->
    Meteor.user()?.username
  adminView: -> adminView()
Template.mainLayout.events
  'submit .to-admin': (event) ->
    password = event.target.password.value
    unless password is ''
      Meteor.loginWithPassword "Admin", password, (err) ->
        console.error err if err
    event.target.password.value = ''
    return false
  'click #logout-btn': (event) ->
    Meteor.loginWithPassword "guest", "guest"
    return false
  'click .show-inactive': (event) ->
    if Session.get 'showInactive'
      $(event.target).removeClass "checked"
      Session.set 'showInactive', false
    else
      $(event.target).addClass "checked"
      Session.set 'showInactive', true
    return false
Template.members.helpers
  members: -> 
    if Session.get('showInactive')
      return Members.find {}, sort: lastCoffee: 1
    else
      return Members.find { active: $ne: false }, sort: lastCoffee: 1
  adminView: -> adminView()
memberRowHelpers =
  lastCoffeeDate: ->
    if @lastCoffee? then return dateToString @lastCoffee else return ''
  lastCoffeeDaysSince: ->
    return '∞' unless @lastCoffee?
    Math.round (new Date() - @lastCoffee) / 1000 / 60 / 60 / 24
  inactive: ->
    not @active
  adminView: -> adminView()
memberRowEvents =
  'click .toggle-active': ->
    return false unless Meteor.user()?.username is 'Admin'
    Members.update @_id, $set: active: !@active
    return false
  'click .delete': ->
    return false unless Meteor.user()?.username is 'Admin'
    Members.remove @_id
    return false
  'click .coffee': ->
    return false unless Meteor.user()?.username is 'Admin'
    date = new Date()
    Members.update @_id, {$push: {dates: date}, $set: {lastCoffee: date}}
    return false
Template.memberRow.helpers memberRowHelpers
Template.memberRow.events memberRowEvents
Template.memberRowAdmin.helpers memberRowHelpers
Template.memberRowAdmin.events memberRowEvents
memberRowHelpers.dates = ->
  return @dates.reverse()
memberRowHelpers.dateToString = ->
  return dateToString @
Template.member.helpers memberRowHelpers

Template.newMemberForm.events
  'submit form': (event) ->
    event.preventDefault();
    return false unless Meteor.user()?.username is 'Admin'
    name = event.target.name.value
    email = event.target.email.value
    if name.length > 0 and email.length > 0
      Members.insert
        name: name
        email: email
        active: true
        dates: []
        createdAt: new Date()
    event.target.name.value = ''
    event.target.email.value = ''
    $('#newMemberModal').modal('hide')
    return false

Template.emailForm.events
  'submit form': (event) ->
    event.preventDefault();
    sendBtn = $("#send-email").button('sending')
    Meteor.call 'sendEmail', (err, result) ->
      if result?.statusCode is 200
        sendBtn.button('sent')
        setTimeout ->
          sendBtn.button('reset')
        , 2000
      else if result?.statusCode is 400
        sendBtn.button('reset')
        $('#alertMessage').text result.body
        alert = $('.alert').show()
        setTimeout ->
          alert.hide()
        , 3000
    return false
