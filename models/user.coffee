mongoose = require 'mongoose'

userSchema = new mongoose.Schema
  id:          String  # jawbone user_xid
  first_name:  String
  last_name:   String
  screen_name: String  # username on 俺API
  icon:        String  # icon URL
  token:       String  # oauth token
  refresh_token: String

userSchema.statics.findOne_by_id = (user_id, callback) ->
  return @findOne {id: user_id}, callback

userSchema.methods.fullname = ->
  return "#{@first_name} #{@last_name}"

User = mongoose.model 'User', userSchema
