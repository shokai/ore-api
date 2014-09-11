## 起きたらラジオ体操.mp3を再生する

url = process.argv[2] or 'http://localhost:10000'
# url = process.argv[2] or 'https://ore-api.herokuapp.com'

{exec} = require 'child_process'

socket = require('socket.io-client').connect(url)

socket.on 'sleep', (event) ->
  console.log "sleep event"
  console.log event
  if e.action is 'creation' and e.screen_name is 'shokai'
    exec 'afplay /Users/sho/ラジオ体操.mp3'

socket.on 'connect', ->
  console.log "connect!! - #{url}"
