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

  app.get '/:user_id/status.json', (req, res) ->
    user_id = req.params.user_id
    Event.last_move_of_user user_id, (err, events) ->
      if err
        return res.status(500).end JSON.stringify {error: "server error"}
      unless event = events[0]
        return res.status(404).end JSON.stringify {}

      # 1時間以内に動いてたら生きてる判定
      status =
        if Date.now()/1000 - event.get('timestamp') < config.status.move_expire
        then "up"
        else "down"

      res.end JSON.stringify {status: status}
