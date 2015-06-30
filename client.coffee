io = require 'socket.io-client'
socket = io.connect 'http://localhost:4040'

randColor = ->
  o = -> Math.floor(Math.random()*256)
  "rgb(#{o()},#{o()},#{o()})"

class Canvas 
  constructor: (sel) ->
    @el = document.querySelector sel
    @ctx = @el.getContext '2d'
    @width = @el.getAttribute 'width'
    @height = @el.getAttribute 'height'
    @color = randColor()
    @x = 0

  clear: ->
    @x=0
    @ctx.clearRect(0,0,@width,@height)

  addFrame: (size) ->
    if @x > @width then @clear()
    y = @height - @height*size
    @ctx.fillStyle = @color
    @ctx.fillRect @x, y, 1, @height - y
    @x++


audioElement = document.querySelector('audio')
audioCtx = new AudioContext()

# freqCanvas = new Canvas '#freq'
# amplitudeCanvas = new Canvas '#amp'

energyCanvasH  = new Canvas '#energyHigh'
energyCanvasMH = new Canvas '#energyMidHigh'
energyCanvasML = new Canvas '#energyMidLow'
energyCanvasL  = new Canvas '#energyLow'

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

  # drawFreq()
  drawEnergy()
  # drawAmp()

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
  if !pause then requestAnimationFrame drawEnergy

  analyser.getByteFrequencyData(dataArray)
  eH = eMH = eML = eL = 0

  for i in [0..bufferLength]
    val = dataArray[i]
    if i < (bufferLength / 4)
      eL += val
    else if i < (bufferLength / 2)
      eML += val
    else if i < (3*bufferLength / 4)
      eMH += val
    else if i < bufferLength
      eH += val

  normalized = [eH, eMH, eML, eL].map (number) ->
    return number / (dataArray.length * 255)

  energyCanvasH.addFrame(normalized[0]) 
  energyCanvasMH.addFrame(normalized[1])
  energyCanvasML.addFrame(normalized[2])
  energyCanvasL.addFrame(normalized[3]) 


  # normEnergy = energy / (dataArray.length * 255)
  # console.log "eh: #{eH}\neMH: #{eMH}\neML: #{eML}\neL: #{eL}\n"








