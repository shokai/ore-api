path    = require 'path'
debug   = require('debug')('ore:app')
config  = require path.resolve 'config.json'
express = require 'express'

process.env.PORT ||= 3000

app = express()
app.set 'view engine', 'jade'
app.use express.static path.resolve 'public'
app.config = config

for name in ['main']
  require(path.resolve 'controllers', name)(app)

app.listen process.env.PORT
debug "server start - port:#{process.env.PORT}"
