mongoose = require 'mongoose'

userSchema = new mongoose.Schema
  id: String
  first_name: String
  last_name: String
  icon: String
  token: String
  refresh_token: String

userSchema.statics.find_by_id = (user_id) ->
  return this.findOne {id: user_id}

userSchema.methods.fullname = ->
  return "#{this.first_name} #{this.last_name}"

User = mongoose.model 'User', userSchema
