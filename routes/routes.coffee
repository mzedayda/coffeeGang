Members = null
Meteor.startup ->
  Members = share.collections.members

Router.configure
  layoutTemplate: 'masterLayout'

Router.route '/', ->
  @render 'members'
Router.route '/members/:name', ->
  @render 'member', {data: -> return Members.findOne {name: @params.name}}

Router.route('/members', { where: 'server' }).get ->
  @response.end JSON.stringify Members.find({}, fields: {_id: false}).fetch()