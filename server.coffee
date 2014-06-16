path    = require 'path'
debug   = require('debug')('ore:app')
config  = require path.resolve 'config.json'
express = require 'express'
cookieParser = require 'cookie-parser'
session = require 'express-session'

process.env.PORT ||= 3000

app = express()
app.set 'view engine', 'jade'
app.use express.static path.resolve 'public'
app.use cookieParser()
app.use session
  secret: (process.env.SESSION_SECRET or 'うどん居酒屋 かずどん')
  cookie:
    maxAge: 7*24*60*60*1000
app.config = config

for name in ['main', 'auth']
  require(path.resolve 'controllers', name)(app)

app.listen process.env.PORT
debug "server start - port:#{process.env.PORT}"
