Members = null
Meteor.startup ->
  Members = share.collections.members

Picker.route "/members", (params, req, res) ->
  res.end JSON.stringify Members.find({}, fields: { _id: false }).fetch()