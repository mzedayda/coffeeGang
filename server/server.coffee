Members = null

Meteor.startup ->
  Members = share.collections.members
  seed()
  return

seed = ->
  datify = (member) ->
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
  
  Members.remove {}
  members = JSON.parse Assets.getText "members.json"
  for member in members or []
    Members.insert datify member