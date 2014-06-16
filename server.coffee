express = require 'express'

app = express()
app.set 'view engine', 'jade'

app.get '/', (req, res) ->
  return res.render 'index', {
    title: '俺API'
  }

app.listen 3000
