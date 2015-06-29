io = require 'socket.io-client'
freqCanvas = null
energyCanvas = null
pause = true

class Canvas 
  constructor: (sel) ->
    @el = document.querySelector sel
    @ctx = @el.getContext '2d'
    @width = @el.getAttribute 'width'
    @height = @el.getAttribute 'height'
    @x = 0

  clear: ->
    @ctx.fillRect 0, 0, @width, @height

audioElement = document.querySelector('audio')
audioCtx = new AudioContext()


socket = io.connect 'http://localhost:4040'

analyser = audioCtx.createAnalyser()
analyser.fftSize = 64
bufferLength = analyser.frequencyBinCount
dataArray = new Uint8Array bufferLength

audioElement.addEventListener 'play', ->
  pause = false

  source = audioCtx.createMediaElementSource audioElement
  source.connect analyser
  analyser.connect audioCtx.destination

  freqCanvas = new Canvas '#freq'
  energyCanvas = new Canvas '#energy'

  drawFreq()
  drawEnergy()

audioElement.addEventListener 'pause', ->
  pause = true

drawFreq = ->
  if pause then return
  requestAnimationFrame drawFreq
  analyser.getByteFrequencyData(dataArray)
  freqCanvas.ctx.fillStyle = 'rgb(0,0,0)'
  freqCanvas.clear()

  barWidth = (freqCanvas.width / bufferLength) * 2.5

  x = 0
  for i in [0..bufferLength]
    barHeight = dataArray[i] 
    freqCanvas.ctx.fillStyle =  "rgb(#{barHeight+100},50,50)"
    freqCanvas.ctx.fillRect(x, freqCanvas.height-barHeight/2, barWidth, barHeight)
    x += barWidth + 1


drawEnergy = ->
  if pause then return
  requestAnimationFrame drawEnergy
  analyser.getByteFrequencyData(dataArray)
  energy = [].reduceRight.call dataArray, (p,c)->p+c
  normEnergy = energy / (dataArray.length * 255)

  energyCanvas.ctx.beginPath()

  x = energyCanvas.x
  y = energyCanvas.height - energyCanvas.height*normEnergy

  energyCanvas.ctx.fillStyle = 'red'
  energyCanvas.ctx.fillRect x, y, 1, 1
  energyCanvas.x++









