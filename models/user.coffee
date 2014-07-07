mongoose  = require 'mongoose'
jawboneUp = require 'jawbone-up'
debug_    = require('debug')('ore:model:user')
debug     = (msg) ->
  debug_ msg
  return msg

module.exports = (app) ->

  userSchema = new mongoose.Schema
    id:          String  # jawbone user_xid
    first_name:  String
    last_name:   String
    screen_name:  # username on 俺API
      type:   String
      unique: true
      validate: [
        (v) ->
          v.length < 16 and /^[a-z\d_\-]+$/i.test v
        'Invalid screen_name'
      ]
    icon:        String  # icon URL
    token:       String  # oauth token
    refresh_token: String

  userSchema.methods.fullname = ->
    return "#{@first_name} #{@last_name}"

  userSchema.statics.findOne_by_id = (user_id, callback) ->
    return @findOne {id: user_id}, callback

  userSchema.statics.findOne_by_screen_name = (screen_name, callback) ->
    return @findOne {screen_name: screen_name}, callback

  userSchema.methods.last_move = (callback) ->
    return mongoose.model('Event').last_move_of_user @id, callback

  userSchema.methods.up = ->
    return jawboneUp
      access_token: @token
      client_secret: process.env.CLIENT_ID

  userSchema.methods.sleeps = (callback) ->
    @up().sleeps.get {}, (err, res) ->
      if err
        callback err
        return
      try
        res = JSON.parse res
        debug "jawbone-api - got #{res.data.items.length} sleeps"
        callback null, res
      catch e
        callback e

  mongoose.model 'User', userSchema
