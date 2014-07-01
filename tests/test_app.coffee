path = require 'path'
require path.resolve 'tests', 'test_helper'

assert   = require 'assert'
request  = require 'supertest'
mongoose = require 'mongoose'
app      = require path.resolve 'app'


describe '俺API', ->

  it 'sohuld have index page', (done) ->
    request app
    .get '/'
    .expect 200
    .expect 'Content-Type', /text/
    .end done

  it 'should have route /webhook', (done)->
    request app
    .post '/webhook'
    .expect 500
    .end done

  it 'should have route /status.json', (done) ->
    request app
    .get '/SomeOne/status.json'
    .expect 404
    .end done


  describe 'model "User"', ->

    User = mongoose.model 'User'

    it 'should have method "findOne_by_id"', ->
      assert.equal typeof User['findOne_by_id'], 'function'

    it 'should have method "findOne_by_screen_name"', ->
      assert.equal typeof User['findOne_by_screen_name'], 'function'
