jawboneUp = require 'jawbone-up'
debug     = require('debug')('ore:controller:auth')

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
      req.session.jawbone =
        token: token.token.access_token
      up = jawboneUp
        access_token:  token.token.access_token
        client_secret: process.env.CLIENT_ID
      up.me.get {}, (up_err, up_res) ->
        if up_err
          return res.redirect '/'
        up_res = JSON.parse up_res
        req.session.jawbone.icon = "https://jawbone.com/#{up_res.data.image}"
        req.session.jawbone.name = "#{up_res.data.first} #{up_res.data.last}"
        return res.redirect '/'


  app.get '/logout', (req, res) ->
    req.session.destroy()
    res.redirect '/'
