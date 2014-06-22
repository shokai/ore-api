## subscribe jawbone's webhook event

url = process.argv[2] or 'http://localhost:10000'

socket = require('socket.io-client').connect(url)

socket.on 'connect', ->
  console.log "connect!! - #{url}"

socket.on 'move', (event) ->
  console.log "move event"
  console.log event

socket.on 'sleep', (event) ->
  console.log "sleep event"
  console.log event
