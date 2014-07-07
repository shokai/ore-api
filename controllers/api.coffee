debug    = require('debug')('ore:controller:api')
mongoose = require 'mongoose'
User     = mongoose.model 'User'
Event    = mongoose.model 'Event'

module.exports = (app) ->

  config       = app.get 'config'
  package_json = app.get 'package'
  io           = app.get 'socket.io'

  app.post '/webhook', (req, res) ->
    debug "webhook pubsub (events:#{req.body.events?.length}) - #{JSON.stringify req.body}"
    Event.insert_webhook req.body, (err, events) ->
      for event in events
        User.findOne_by_id event.user_xid, (err, user) ->
          return if err or !user?
          event.screen_name = user.screen_name
          io.sockets.emit event.type, event
    return res.end "ok"

