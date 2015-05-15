Members = new (Mongo.Collection)('members')
if Meteor.isClient
  Meteor.loginWithPassword "guest", "guest", (err) ->
    console.error err if err
  adminView = ->
    Meteor.user()?.username is 'Admin'
  Template.body.helpers
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
    guestView: -> !adminView()
  Template.body.events
    'submit .to-admin': (event) ->
      password = event.target.password.value
      unless password is ''
        Meteor.loginWithPassword "Admin", password, (err) ->
          console.error err if err
      event.target.password.value = ''
      false
    'click #logout-btn': (event) ->
      console.log "clicked"
      Meteor.loginWithPassword "guest", "guest"
      false
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
      false
    'change .show-inactive input': (event) ->
      Session.set 'showInactive', event.target.checked
      return
  Template.member.helpers
    lastCoffeeDate: ->
      "#{@lastCoffee.getDate()}/#{@lastCoffee.getMonth()+1}/#{@lastCoffee.getFullYear() % 100}"
    lastCoffeeDaysSince: ->
      return 0 unless @lastCoffee?
      Math.round (new Date() - @lastCoffee) / 1000 / 60 / 60 / 24
    inactive: ->
      not @active
    adminView: -> adminView()
  Template.member.events
    'click .toggle-active': ->
      return false unless Meteor.user()?.username is 'Admin'
      Members.update @_id, $set: active: !@active
      return
    'click .delete': ->
      return false unless Meteor.user()?.username is 'Admin'
      Members.remove @_id
      return
    'click .coffee': ->
      return false unless Meteor.user()?.username is 'Admin'
      date = new Date()
      Members.update @_id, {$push: {dates: date}, $set: {lastCoffee: date}}
      return

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
    Members.insert
      name: "Netanel"
      active: false
      dates: [new Date("07-11-2013Z"), new Date("11-07-2013Z"), new Date("04-01-2014Z")]
      lastCoffee: new Date("04-01-2014Z")
      createdAt: new Date()
    Members.insert
      name: "Ohad"
      active: true
      dates: [new Date("02-17-2014Z"), new Date("08-26-2014Z"), new Date("03-22-2015Z")]
      lastCoffee: new Date("03-22-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Anna"
      active: true
      dates: [new Date("02-16-2014Z"), new Date("08-21-2014Z"), new Date("03-08-2015Z")]
      lastCoffee: new Date("03-08-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Motti"
      active: false
      dates: [new Date("07-08-2013Z"), new Date("10-13-2013Z"), new Date("01-19-2014Z"), new Date("06-15-2014Z"), new Date("06-15-2014Z")]
      lastCoffee: new Date("06-15-2014Z")
      createdAt: new Date()
    Members.insert
      name: "Bumi"
      active: true
      dates: [new Date("06-10-2013Z"), new Date("09-29-2013Z"), new Date("12-23-2013Z"), new Date("05-26-2014Z"), new Date("11-20-2014Z"), new Date("04-15-2015Z")]
      lastCoffee: new Date("04-15-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Ron"
      active: true
      dates: [new Date("05-12-2013Z"), new Date("08-13-2013Z"), new Date("11-26-2013Z"), new Date("04-13-2014Z"), new Date("10-20-2014Z"), new Date("04-01-2015Z")]
      lastCoffee: new Date("04-01-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Lior"
      active: false
      dates: [new Date("01-20-2014Z")]
      lastCoffee: new Date("01-20-2014Z")
      createdAt: new Date()
    Members.insert
      name: "Yael"
      active: true
      dates: [new Date("08-04-2014Z"), new Date("02-18-2015Z")]
      lastCoffee: new Date("02-18-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Hetan"
      active: true
      dates: [new Date("01-04-2015Z"), new Date("05-04-2015Z")]
      lastCoffee: new Date("05-04-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Nastia"
      active: true
      dates: [new Date("01-20-2015Z")]
      lastCoffee: new Date("01-20-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Leora"
      active: true
      dates: [new Date("01-11-2015Z")]
      lastCoffee: new Date("01-11-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Shiluz"
      active: true
      dates: [new Date("02-03-2015Z")]
      lastCoffee: new Date("02-03-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Shir A."
      active: false
      dates: [new Date("03-03-2015Z")]
      lastCoffee: new Date("03-03-2015Z")
      createdAt: new Date()
    Members.insert
      name: "Yuval"
      active: true
      dates: [new Date("05-11-2015Z")]
      lastCoffee: new Date("05-11-2015Z")
      createdAt: new Date()
  Meteor.startup ->
    # code to run on server at startup
    seed()
    return