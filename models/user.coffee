mongoose = require 'mongoose'

userSchema = new mongoose.Schema
  xid: String
  first_name: String
  last_name: String
  icon: String
  token: String
  refresh_token: String

userSchema.statics.find_by_xid = (xid) ->
  return this.findOne {xid: xid}

userSchema.methods.fullname = ->
  return "#{this.first_name} #{this.last_name}"

User = mongoose.model 'User', userSchema
