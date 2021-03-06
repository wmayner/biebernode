// Generated by CoffeeScript 1.4.0
var app, colors, express, http, path;

express = require('express');

http = require('http');

path = require('path');

colors = require('colors');

app = express();

app.configure(function() {
  app.use(express.logger('dev'));
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon(path.join(__dirname, '/public/img/favicon.ico')));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  return app.use(express["static"](path.join(__dirname, '/public')));
});

app.configure('development', function() {
  return app.use(express.errorHandler());
});

app.get('/', function(req, res) {
  return res.render('bieber');
});

app.listen(app.get('port'));

console.log(("Express server listening on port " + (app.get('port'))).green.inverse);
