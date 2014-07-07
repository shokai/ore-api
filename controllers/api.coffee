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


  app.get '/:screen_name/status.json', (req, res) ->
    screen_name = req.params.screen_name
    res.set 'Content-Type', 'application/json; charset=utf-8'

    User.findOne_by_screen_name screen_name, (err, user) ->
      if err
        res.status(500).end JSON.stringify
          error: "server error"
        return
      unless user
        res.status(404).end JSON.stringify
          error: "user not found"
        return
      user.last_move (err, events) ->
        if err
          return res.status(500).end JSON.stringify
            error: "server error"
        unless event = events[0]
          return res.status(404).end JSON.stringify {}

        # 一定期間内にmoveしていたら、生きてる判定
        status =
          if Date.now()/1000 - event.get('timestamp') < config.status.move_expire
          then "up"
          else "down"

        res.end JSON.stringify {status: status}

  app.get '/:screen_name/sleeps.json', (req, res) ->
    screen_name = req.params.screen_name
    res.set 'Content-Type', 'application/json; charset=utf-8'

    User.findOne_by_screen_name screen_name, (err, user) ->
      if err
        res.status(500).end JSON.stringify
          error: "server error"
        return
      unless user
        res.status(404).end JSON.stringify
          error: "user not found"
        return

      user.sleeps (err, sleeps) ->
        if err
          res.status(500).end JSON.stringify
            error: "jawbone-up api error"
          return
        res.end JSON.stringify sleeps
