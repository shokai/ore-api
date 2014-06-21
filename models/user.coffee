mongoose = require 'mongoose'

userSchema = new mongoose.Schema
  id: String
  first_name: String
  last_name: String
  icon: String
  token: String
  refresh_token: String

userSchema.statics.findOne_by_id = (user_id, callback) ->
  return @findOne {id: user_id}, callback

userSchema.methods.fullname = ->
  return "#{@first_name} #{@last_name}"

User = mongoose.model 'User', userSchema
