io = require 'socket.io-client'
socket = io.connect 'http://localhost:4040'

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

freqCanvas = new Canvas '#freq'
energyCanvas = new Canvas '#energy'
amplitudeCanvas = new Canvas '#amp'

pause = true

analyser = audioCtx.createAnalyser()
analyser.fftSize = 64
bufferLength = analyser.frequencyBinCount
dataArray = new Uint8Array bufferLength

audioElement.addEventListener 'play', ->
  pause = false

  source = audioCtx.createMediaElementSource audioElement
  source.connect analyser
  analyser.connect audioCtx.destination

  drawFreq()
  drawEnergy()
  drawAmp()

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

drawAmp = ->
  if pause then return
  requestAnimationFrame drawAmp
  analyser.getByteTimeDomainData dataArray
  total = [].reduceRight.call dataArray, (p,c)->p+c
  mean = total / (dataArray.length * 255)

  x = amplitudeCanvas.x
  y = amplitudeCanvas.height - amplitudeCanvas.height*mean

  amplitudeCanvas.ctx.fillStyle = 'blue'
  amplitudeCanvas.ctx.fillRect x, y, 1, amplitudeCanvas.height - y
  amplitudeCanvas.x++

drawEnergy = ->
  if pause then return
  requestAnimationFrame drawEnergy
  analyser.getByteFrequencyData(dataArray)
  energy = [].reduceRight.call dataArray, (p,c)->p+c
  normEnergy = energy / (dataArray.length * 255)

  x = energyCanvas.x
  y = energyCanvas.height - energyCanvas.height*normEnergy

  energyCanvas.ctx.fillStyle = 'red'
  energyCanvas.ctx.fillRect x, y, 1, energyCanvas.height - y
  energyCanvas.x++









