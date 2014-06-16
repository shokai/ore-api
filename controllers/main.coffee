debug = require('debug')('ore:controller')

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

  app.get '/', (req, res) ->
    console.log req.session
    args =
      title: app.config.title
      login_jawbone: req.session.jawbone_token?

    return res.render 'index', args


  app.get '/login', (req, res) ->
    auth_url = OAuth2.AuthCode.authorizeURL
      redirect_uri: "#{req.protocol}://#{req.headers.host}/auth"
      scope: "basic_read extended_read mood_read move_read sleep_read generic_event_read"
    res.redirect auth_url


  app.get '/auth', (req, res) ->
    unless code = req.query.code
      return res.redirect '/'

    OAuth2.AuthCode.getToken {
      code: code,
      redirect_uri: "#{req.protocol}://#{req.headers.host}/auth"
    }, (token_err, token_res) ->
      if token_err
        return res.redirect '/'
      token = OAuth2.AccessToken.create token_res
      req.session.jawbone_token = token.token.access_token
      return res.redirect '/'


  app.get '/logout', (req, res) ->
    req.session.destroy()
    res.redirect '/'
