# Module dependencies.
express = require 'express'
http    = require 'http'
path    = require 'path'
colors  = require 'colors'

app = express()

app.configure () ->
  app.use express.logger('dev')
  app.set 'port', process.env.PORT || 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon(path.join(__dirname, '/public/img/favicon.ico'))
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, '/public'))

app.configure 'development', () ->
  app.use express.errorHandler()

app.get '/', (req, res) -> res.render('bieber')

app.listen app.get 'port'
console.log "Express server listening on port #{app.get 'port'}".green.inverse
