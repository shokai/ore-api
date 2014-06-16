module.exports = (app) ->

  app.get '/', (req, res) ->
    console.log req.session
    unless req.session?.count
      req.session.count = 0
    req.session.count += 1

    args =
      title: app.config.title
      count: req.session.count
    return res.render 'index', args
