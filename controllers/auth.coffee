jawboneUp = require 'jawbone-up'
debug     = require('debug')('ore:controller:auth')
mongoose  = require 'mongoose'
User      = mongoose.model 'User'

unless process.env.CLIENT_ID? and process.env.APP_SECRET?
  console.error "please set CLEINT_ID and APP_SECRET"
  process.exit 1

OAuth2  = require('simple-oauth2')(
  clientID: process.env.CLIENT_ID
  clientSecret: process.env.APP_SECRET
  site: 'https://jawbone.com'
  tokenPath: '/auth/oauth2/token'
  authorizationPath: '/auth/oauth2/auth'
)

module.exports = (app) ->

  app.get '/login', (req, res) ->
    if req.session.jawbone?.token?
      return res.redirect '/'
    protocol = if process.env.NODE_ENV is 'production' then 'https' else req.protocol
    auth_url = OAuth2.AuthCode.authorizeURL
      redirect_uri: "#{protocol}://#{req.headers.host}/auth"
      scope: "basic_read extended_read mood_read move_read sleep_read generic_event_read"
    return res.redirect auth_url


  app.get '/auth', (req, res) ->
    unless code = req.query.code
      return res.redirect '/'

    protocol = if process.env.NODE_ENV is 'production' then 'https' else req.protocol
    OAuth2.AuthCode.getToken {
      code: code,
      redirect_uri: "#{protocol}://#{req.headers.host}/auth"
    }, (token_err, token_res) ->
      if token_err
        return res.redirect '/'
      token = OAuth2.AccessToken.create token_res
      debug "token - #{token.token.access_token}"

      up = jawboneUp
        access_token:  token.token.access_token
        client_secret: process.env.CLIENT_ID

      up.me.get {}, (up_err, up_res) ->
        if up_err
          return res.redirect '/'
        up_res = JSON.parse up_res
        req.session.xid = up_res.data.xid
        User.find_by_xid(up_res.data.xid).exec (err, user) ->
          if err
            return res.redirect '/'
          unless user
            user = new User {xid: up_res.data.xid}
          user.token = token.token.access_token
          user.refresh_token = token.token.refresh_token
          user.icon = "https://jawbone.com/#{up_res.data.image}"
          user.first_name = up_res.data.first
          user.last_name = up_res.data.last
          user.save (err) ->
            if err
              debug 'user save error'
              debug err
              return res.redirect '/'
            up.webhook.create "#{protocol}://#{req.headers.host}/pubsub", (pubsub_err, pubsub_res) ->
              if pubsub_err
                debug 'pubsub register error'
                debug pubsub_err
              return res.redirect '/'


  app.get '/logout', (req, res) ->
    req.session.destroy()
    res.redirect '/'
