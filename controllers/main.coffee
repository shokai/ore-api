debug = require('debug')('ore:controller:main')

module.exports = (app) ->

  app.get '/', (req, res) ->
    args =
      title: app.config.title
      login_jawbone: req.session.jawbone_token?

    return res.render 'index', args