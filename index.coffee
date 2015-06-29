express = require('express')
fs = require 'fs'
browserify = require 'browserify'

app = express()
server = app.listen(4040)
io = require('socket.io').listen(server)


app.use(express.static(__dirname + '/public'));

app.get '/bundle.js', (req, res) ->
  browserify('./client.coffee', {
    transform: [require 'coffeeify']
  }).bundle().pipe(res);

app.get '/FourtetStream.mp3', (req, res) ->
  fs.createReadStream("#{__dirname}/audio/Fourtet.mp3")
    .pipe(res)

io.on 'connection', (socket) ->

  socket.on 'stream_init', (message) ->

    mp3Stream = new MStream("#{__dirname}/audio/Fourtet.mp3")

    mp3Stream.on 'data', (dat) ->
        socket.emit 'data', dat
      .on 'error', (er) ->
        throw er

    # readStream.on 'end', ->
      # console.log buffers[0].toString()


  socket.on 'error', (err) -> console.log err