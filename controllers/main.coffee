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

      return res.redirect "/#{user.screen_name}"


  app.get '/:screen_name', (req, res) ->

    screen_name = req.params.screen_name
    args =
      title: config.title
      user:
        is_login: false
      app:
        url: "#{req.protocol}://#{req.headers.host}"
        homepage: package_json.homepage

    User.findOne_by_screen_name screen_name, (err, user) ->
      if err
        return res.status(500).end 'server error'

      unless user
        return res.status(400).end 'user not found'

      Event.find_by_user user.id, (err, events)->
        args.user =
          is_login: user.token? and user.id is req.session.user_id
          icon:  user.icon
          fullname:  user.fullname()
          screen_name: user.screen_name
          events: events.length

        return res.render 'user', args


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
