util     = require 'util'
debug    = require('debug')('ore:controller:main')
mongoose = require 'mongoose'
User     = mongoose.model 'User'
Event    = mongoose.model 'Event'

module.exports = (app) ->

  config       = app.get 'config'
  package_json = app.get 'package'

  app.get '/', (req, res) ->

    args =
      title: config.title
      user:
        is_login: false
      app:
        url: "#{req.protocol}://#{req.headers.host}"
        homepage: package_json.homepage

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
