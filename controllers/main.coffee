module.exports = (app) ->

  app.get '/', (req, res) ->
    args =
      title: app.config.title
    return res.render 'index', args


