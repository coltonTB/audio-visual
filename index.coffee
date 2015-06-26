express = require('express')
ss = require 'socket.io-stream'
fs = require 'fs'
lame = require 'lame'
browserify = require 'browserify'

app = express()
server = app.listen(4040)
io = require('socket.io').listen(server)

app.use(express.static(__dirname + '/public'));

app.get '/bundle.js', (req, res) ->
  browserify('./client.coffee', {
    transform: [require 'coffeeify']
  }).bundle().pipe(res);

io.on 'connection', (socket) ->

  ss(socket).on 'stream_init', (stream) ->
    str = fs.createReadStream("#{__dirname}/audio/Fourtet.mp3")
      .pipe(stream)


  socket.on 'error', (err) -> console.log err