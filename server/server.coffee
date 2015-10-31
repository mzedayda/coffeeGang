Members = null
internals = {}

Meteor.startup ->
  process.env.MAIL_URL = "smtp://noreply.coffeegang@gmail.com:Foxtrot1@smtp.gmail.com:465/"
  Members = share.collections.members
  seed()
  return

seed = ->
  datify = (member) ->
    if member.lastCoffee?
      member.lastCoffee = new Date member.lastCoffee
    for date, index in member.dates
      member.dates[index] = new Date date
    return member

  Meteor.users.remove {}
  Accounts.createUser
    username: "Admin"
    password: "30081990"
  Accounts.createUser
    username: "guest"
    password: "guest"
  
  unless Members.findOne()?
    members = JSON.parse Assets.getText "members.json"
    for member in members or []
      Members.insert datify member

internals.lastReminder = null
internals.minWait = 2 * 60 * 60 * 1000
Meteor.methods
  sendEmail: ->
    @unblock()
    now = new Date()
    return {statusCode: 400, body: "An Email reminder was recently sent, don't spam!"} unless now - internals.lastReminder > internals.minWait
    member = Members.findOne { active: true }, sort: lastCoffee: 1
    return {statusCode: 400, body: "Error: No active members"} unless member?
    return {statusCode: 400, body: "Error: We don't know #{member.name}'s email :( . Blame Hetan"} unless member.email?
    line1 = "Hi #{member.name},\nOur precious coffee is running out and your turn is up.\nPlease bring a new package a soon as possible, thanks!"
    line2 = "Visit coffeegang.meteor.com for more information"
    line3 = "This mail was sent to #{member.email} by the coffeegang app by @mzedayda"
    Email.send
      to: member.email
      from: "noreply.coffeegang@gmail.com"
      subject: "Coffee Reminder"
      text: line1 + "\n\n" + line2 + "\n\n\n\n" + line3
    internals.lastReminder = now
    return {statusCode: 200, body: "Email was sent to #{member.name}"}