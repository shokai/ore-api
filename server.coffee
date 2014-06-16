path    = require 'path'
config  = require path.resolve 'config.json'
express = require 'express'

app = express()
app.set 'view engine', 'jade'
app.use express.static path.resolve 'public'

app.get '/', (req, res) ->
  return res.render 'index', {
    title: config.title
  }

app.listen 3000
