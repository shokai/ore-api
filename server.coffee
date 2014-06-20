path    = require 'path'
debug   = require('debug')('ore:app')
express = require 'express'
mongo   = require 'mongoose'

## config
config  = require path.resolve 'config.json'
process.env.PORT ||= 3000


## express modules
cookieParser = require 'cookie-parser'
session      = require 'express-session'
MongoStore   = require('connect-mongo')(session)
bodyParser   = require 'body-parser'


## setup server ##
app = express()
app.set 'view engine', 'jade'
app.use express.static path.resolve 'public'
app.use cookieParser()
app.use bodyParser.json()
app.config = config


## model & session ##
mongodb_uri = process.env.MONGOLAB_URI or
              process.env.MONGOHQ_URL or
              'mongodb://localhost/ore-api'

mongo.connect mongodb_uri, (err) ->
  if err
    console.error err
    process.exit 1

  app.use session
    secret: (process.env.SESSION_SECRET or 'うどん居酒屋 かずどん')
    store: new MongoStore
      db: mongo.connections[0].db


  ## load controllers & models ##
  for name in ['main', 'auth']
    require(path.resolve 'controllers', name)(app)


  ## start server ##
  app.listen process.env.PORT
  debug "server start - port:#{process.env.PORT}"
