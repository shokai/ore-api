util  = require 'util'
debug = require('debug')('ore:controller:main')

module.exports = (app) ->

  app.get '/', (req, res) ->
    args =
      title: app.config.title
      jawbone:
        login: req.session.jawbone?.token?
        icon:  req.session.jawbone?.icon
        name:  req.session.jawbone?.name
    return res.render 'index', args


  app.post '/pubsub', (req, res) ->
    debug "pubsub json - #{util.inspect req.body}"
    res.end "ok"
