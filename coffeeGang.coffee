Members = new (Mongo.Collection)('members')
Router.configure
  layoutTemplate: 'mainLayout'
Router.route '/', ->
  @render 'members'
Router.route '/members/:name', ->
  @render 'member', {data: -> return Members.findOne {name: this.params.name}}

Router.route('/members', { where: 'server' }).get ->
  @response.end JSON.stringify Members.find({}, fields: {_id: false}).fetch()

if Meteor.isClient
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
        return Members.find { active: $ne: false }, sort: lastCoffee: 1
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
    'submit .new-member': (event) ->
      return false unless Meteor.user()?.username is 'Admin'
      name = event.target.name.value
      unless name is ''
        Members.insert
          name: name
          active: true
          dates: []
          createdAt: new Date()
      event.target.name.value = ''
      return false
    'change .show-inactive input': (event) ->
      Session.set 'showInactive', event.target.checked
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
      return dateToString @lastCoffee
    lastCoffeeDaysSince: ->
      return 0 unless @lastCoffee?
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

if Meteor.isServer
  seed = ->
    Meteor.users.remove {}
    Accounts.createUser
      username: "Admin"
      password: "30081990"
    Accounts.createUser
      username: "guest"
      password: "guest"
    Members.remove {}
    for member in share.seed.members
      Members.insert member
  Meteor.startup ->
    seed()
    return