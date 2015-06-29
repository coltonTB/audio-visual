fs = require 'fs'
util = require 'util'
Readable = require('stream').Readable
parser = require 'mp3-parser'

toArrayBuffer = (buffer) ->
  bufferLength = buffer.length
  uint8Array = new Uint8Array(new ArrayBuffer(bufferLength));
  for i in [0..bufferLength]
    uint8Array[i] = buffer[i]
  return uint8Array.buffer;

getPlayTime = (_view, _lastFrameIndex) ->
  offset = 0
  totalTime = 0
  view = _view
  lastFrameIndex = _lastFrameIndex
  while offset < lastFrameIndex
    frameInfo = parser.readFrame(view, offset)
    if !frameInfo? then break
    frameTime = frameInfo._section.sampleLength /
      frameInfo.header.samplingRate
    totalTime += frameTime
    offset = frameInfo._section.nextFrameIndex
  return totalTime

module.exports = Mp3Stream = (fname) ->

  if not this instanceof Mp3Stream
    return new Mp3Stream fname

  Readable.call this, {objectMode: true}

  @frameBoundary = 2760

  @fd = fs.openSync fname, 'r'

util.inherits(Mp3Stream, Readable)


Mp3Stream.prototype._read = (s) ->

  # fs.read fd, new Buffer(6000), 0, 6000, 0, (err, bytesRead, buffer) ->
  #   v = new DataView toArrayBuffer buffer
  #   tags = parser.readTags(v)
  #   for tag in tags
  #     if tag._section.type is 'frame'
  #       @frameBoundary = tag._section.offset
  #       console.log "fbound: #{@frameBoundary}"

  s = 1024*16
  buf = new Buffer(s)

  fs.read @fd, buf, 0, s, @frameBoundary, (err, bytesRead, buffer) =>

    if err
      fs.close(@fd)
      self.emit 'error', er
      return

    v = new DataView toArrayBuffer buf
    lastFrame = parser.readLastFrame(v)

    if lastFrame?
      @frameBoundary += lastFrame._section.offset
      lastFrameIndex = lastFrame._section.offset
      buf = buffer.slice(0, lastFrameIndex)
      totalTime = getPlayTime(v, lastFrameIndex)
      @push {
        buffer: buf,
        byteLength: buf.length,
        totalDuration: totalTime
      }
    else
      @push null
      fs.close @fd




