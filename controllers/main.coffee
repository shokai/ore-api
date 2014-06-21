util     = require 'util'
debug    = require('debug')('ore:controller:main')
mongoose = require 'mongoose'
User     = mongoose.model 'User'

module.exports = (app) ->

  app.get '/', (req, res) ->

    args =
      title: app.config.title
      jawbone:
        login: false

    unless req.session.user_id
      return res.render 'index', args

    User.find_by_id(req.session.user_id).exec (err, user) ->
      args.jawbone =
        login: user?.token?
        icon:  user?.icon
        fullname:  user?.fullname()

      return res.render 'index', args


  app.post '/pubsub', (req, res) ->
    debug "pubsub json - #{util.inspect req.body}"
    unless req.body.events instanceof Array
      debug typeof req.body.events
      debug 'pubsub format error'
      return res.status(400).end "bad data"
    events_collection = mongoose.connections[0].db.collection 'events'
    for event in req.body.events
      do (event) ->
        for prop in ['user_xid', 'event_xid', 'timestamp', 'type']
          return unless event.hasOwnProperty prop
        events_collection.insert event, (err) ->
          if err
            debug 'event save error'
            debug err
    return res.end "ok"
