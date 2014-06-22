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
      user:
        is_login: false
      app:
        url: "#{req.protocol}://#{req.headers.host}"

    unless req.session.user_id
      return res.render 'index', args

    User.findOne_by_id req.session.user_id, (err, user) ->
      if err or !user?
        return res.render 'index', args

      Event.find_by_user user.id, (err, events)->
        args.user =
          is_login: user.token?
          icon:  user.icon
          fullname:  user.fullname()
          screen_name: user.screen_name
          events: events.length

        return res.render 'index', args


  app.post '/webhook', (req, res) ->
    debug "webhook pubsub (events:#{req.body.events?.length}) - #{JSON.stringify req.body}"
    Event.insert_webhook req.body
    return res.end "ok"


  app.post '/user', (req, res) ->
    unless screen_name = req.body.screen_name
      return res.redirect '/'
    unless req.session.user_id?
      return res.redirect '/'

    User.findOne_by_id req.session.user_id, (err, user) ->
      if err or !user?
        return res.redirect '/'
      debug "rename screen_name #{user.screen_name} -> #{screen_name}"
      user.screen_name = screen_name
      user.save (err) ->
        if err
          debug err
        return res.redirect '/'


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
