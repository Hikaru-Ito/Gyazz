#
# ExpressによるGyazzサーバのメインプログラム
#

express  = require 'express'
favicon  = require 'serve-favicon'
mongoose = require 'mongoose'
path     = require 'path'
debug    = require('debug')('gyazz:app')

## express modules
bodyParser = require 'body-parser'
multer     = require 'multer'

## Config
package_json = require path.resolve 'package.json'
process.env.PORT ||= 3000

## server setup ##
module.exports = app = express()
app.disable 'x-powered-by'
app.use favicon path.resolve 'public/favicon.ico'
app.use express.static path.resolve 'public'  # public以下のファイルはWikiデータとみなさないようにする
app.set 'view engine', 'jade'
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use multer { dest: './public/upload/'}

if process.env.NODE_ENV isnt 'production'
  app.locals.pretty = true  # jade出力を整形

http = require('http').Server(app)
io = require('socket.io')(http)
app.set 'socket.io', io
app.set 'package', package_json

## load controllers, models, socket.io ##
components =
  models:      [ 'access', 'pair', 'page', 'attr', 'line' ]
  controllers: [ 'api', 'main' ]
  lib:         [ 'png' ]
  sockets:     [ 'readwrite' ]
  events:      [ 'notify' ]

for type, items of components
  for item in items
    debug "load #{type}/#{item}"
    require(path.resolve type, item)(app)

mongodb_uri = process.env.MONGOLAB_URI or
              process.env.MONGOHQ_URL or
              'mongodb://localhost/gyazz'

mongoose.connect mongodb_uri, (err) ->
  if err
    debug "mongoose connect failed"
    debug err
    process.exit 1
    return
  debug "connect MongoDB"

  if process.argv[1] isnt __filename
    return   # if load as a module, do not start HTTP server

  ## start server ##
  http.listen process.env.PORT, ->
    console.log "listening on *:#{process.env.PORT}..."
