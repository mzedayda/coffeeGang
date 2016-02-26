Members = null
Meteor.startup ->
  Members = share.collections.members

Router.route('/members', { where: 'server' }).get ->
  @response.end JSON.stringify Members.find({}, fields: {_id: false}).fetch()