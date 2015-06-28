io = require 'socket.io-client'

class BufferedPlayer

  constructor: (@ctx) ->
    @playHead = 0
    @audioBuffers = []

  addBuffer: (buf) =>
    @audioBuffers.push buf

  play: ->
    firstBuffer = @audioBuffers[0]
    currentBuffer = firstBuffer
    endTime = @ctx.currentTime + firstBuffer.duration

    @_playBuffer firstBuffer
    for buff in @audioBuffers[1..]
      console.log endTime
      @_playBuffer buff, endTime
      endTime += buff.duration

  pause: ->

  seek: (seconds) ->

  _playBuffer: (buffer, time=0) ->
    source = audioCtx.createBufferSource()
    source.buffer = buffer
    source.connect audioCtx.destination
    source.start time



audioCtx = new AudioContext()
buffStream = new BufferedPlayer(audioCtx)
socket = io.connect 'http://localhost:4040'

document.getElementById('btn').addEventListener 'click', ->

  socket.emit 'stream_init', {msg: 'hi'}

  socket.on 'data', (d) ->
    audioCtx.decodeAudioData d.buffer, (decoded) ->
      buffStream.addBuffer decoded

  setTimeout ->
    buffStream.play()
  , 3000


