util     = require 'util'
debug    = require('debug')('ore:controller:main')
mongoose = require 'mongoose'
User     = mongoose.model 'User'
Event    = mongoose.model 'Event'

module.exports = (app) ->

  config = app.get('config')

  app.get '/', (req, res) ->

    args =
      title: config.title
      jawbone:
        login: false

    unless req.session.user_id
      return res.render 'index', args

    User.findOne_by_id req.session.user_id, (err, user) ->
      if err or !user?
        return res.render 'index', args

      Event.find_by_user user.id, (err, events)->
        args.jawbone =
          login: user.token?
          icon:  user.icon
          fullname:  user.fullname()
          events: events.length

        return res.render 'index', args


  app.post '/webhook', (req, res) ->
    debug "webhook pubsub (events:#{req.body.events?.length}) - #{JSON.stringify req.body}"
    Event.insert_webhook req.body
    return res.end "ok"
