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

    unless req.session.xid
      return res.render 'index', args

    User.find_by_xid(req.session.xid).exec (err, user) ->
      args.jawbone =
        login: user?.token?
        icon:  user?.icon
        fullname:  user?.fullname()

      return res.render 'index', args


  app.post '/pubsub', (req, res) ->
    debug "pubsub json - #{util.inspect req.body}"
    res.end "ok"
