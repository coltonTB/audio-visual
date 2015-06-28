express = require('express')
fs = require 'fs'
browserify = require 'browserify'
mp3Stream = require './mp3Stream2.coffee'

app = express()
server = app.listen(4040)
io = require('socket.io').listen(server)


app.use(express.static(__dirname + '/public'));

app.get '/bundle.js', (req, res) ->
  browserify('./client.coffee', {
    transform: [require 'coffeeify']
  }).bundle().pipe(res);

app.get '/FourtetStream.mp3', (req, res) ->
  # mp3Stream('./audio/Fourtet.mp3')
  fs.createReadStream("#{__dirname}/audio/Fourtet.wav")
    .pipe(res)

io.on 'connection', (socket) ->

  socket.on 'stream_init', (message) ->

    mp3Stream("#{__dirname}/audio/Fourtet.mp3")
      .on 'data', (buf) ->
        console.log buf.toString('hex')
        console.log buf.toString('hex').length
        socket.emit 'data', {buffer:buf}
      .on 'error', (er) ->
        throw er

    # readStream.on 'end', ->
      # console.log buffers[0].toString()


  socket.on 'error', (err) -> console.log err