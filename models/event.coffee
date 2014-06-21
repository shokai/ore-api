mongoose = require 'mongoose'
async    = require 'async'
debug_   = require('debug')('ore:model:event')
debug    = (msg) ->
  debug_ msg
  return msg


eventSchema = new mongoose.Schema

eventSchema.statics.find_by_user = (user_id) ->
  return @find {user_xid: user_id}


## save events data from jawbone's webhook pubsub
eventSchema.statics.insert_webhook = (data, callback = ->) ->
  unless data.events instanceof Array
    callback debug 'data should have "events" property'
    return

  async.eachSeries data.events, (event, next) ->
    do (event) ->
      for prop in ['user_xid', 'event_xid', 'timestamp', 'type']
        unless event.hasOwnProperty prop
          next debug "event should have \"#{prop}\" property"
          return
      if event.hasOwnProperty '_id'
        next debug 'event should not have "_id" property'
        return
      mongoose.connections[0].collection('events').insert event, next
  , (err) ->
    callback err


Event = mongoose.model 'Event', eventSchema
