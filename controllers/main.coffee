util     = require 'util'
debug    = require('debug')('ore:controller:main')
mongoose = require 'mongoose'
User     = mongoose.model 'User'
Event    = mongoose.model 'Event'

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


  app.post '/webhook', (req, res) ->
    debug "webhook pubsub (events:#{req.body.events?.length}) - #{util.inspect req.body}"
    Event.insert_webhook req.body
    return res.end "ok"
