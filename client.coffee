io = require 'socket.io-client'

audioElement = document.querySelector('audio')
audioCtx = new AudioContext()
canvasElement = document.querySelector('canvas')
canvasCtx = canvasElement.getContext('2d')
socket = io.connect 'http://localhost:4040'

analyser = audioCtx.createAnalyser()
analyser.fftSize = 512
bufferLength = analyser.frequencyBinCount
dataArray = new Uint8Array bufferLength

WIDTH = canvasElement.getAttribute('width')
HEIGHT = canvasElement.getAttribute('height')
barWidth = (WIDTH / bufferLength) * 2.5

audioElement.addEventListener 'play', ->

  source = audioCtx.createMediaElementSource audioElement
  source.connect analyser
  analyser.connect audioCtx.destination

  draw()

draw = ->
  requestAnimationFrame draw

  analyser.getByteFrequencyData(dataArray)

  canvasCtx.fillStyle = 'rgb(0,0,0)'
  canvasCtx.fillRect 0, 0, WIDTH, HEIGHT
  x = 0
  for i in [0..bufferLength]
    barHeight = dataArray[i]
    canvasCtx.fillStyle =  "rgb(#{barHeight+100},50,50)"
    canvasCtx.fillRect(x, HEIGHT-barHeight/2, barWidth, barHeight/2)
    x += barWidth + 1

