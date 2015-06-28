express = require('express')
ss = require 'socket.io-stream'
fs = require 'fs'
lame = require 'lame'
browserify = require 'browserify'

app = express()
server = app.listen(4040)
io = require('socket.io').listen(server)

encoder = new lame.Encoder({
  # // input 
  channels: 2,        #// 2 channels (left and right) 
  bitDepth: 16,       #// 16-bit samples 
  sampleRate: 44100,  #// 44,100 Hz sample rate 
 
  # // output 
  bitRate: 128,
  outSampleRate: 22050,
  mode: lame.STEREO #// STEREO (default), JOINTSTEREO, DUALCHANNEL or MONO 
});

app.use(express.static(__dirname + '/public'));

app.get '/bundle.js', (req, res) ->
  browserify('./client.coffee', {
    transform: [require 'coffeeify']
  }).bundle().pipe(res);

io.on 'connection', (socket) ->

  socket.on 'stream_init', (message) ->

    console.log message

    fs.createReadStream("#{__dirname}/audio/Fourtet.wav")
      .pipe(encoder)
      .on 'data', (buf) ->
        console.log buf
        socket.emit 'data', {buffer:buf}
      .on 'error', (er) ->
        throw er

    # readStream.on 'end', ->
      # console.log buffers[0].toString()


  socket.on 'error', (err) -> console.log err