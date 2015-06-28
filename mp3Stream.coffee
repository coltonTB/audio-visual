fs = require 'fs'
Readable = require('stream').Readable
parser = require 'mp3-parser'

toArrayBuffer = (buffer) ->
  bufferLength = buffer.length
  uint8Array = new Uint8Array(new ArrayBuffer(bufferLength));
  for i in [0..bufferLength]
    uint8Array[i] = buffer[i]
  return uint8Array.buffer;


module.exports = (fname) ->
  fd = fs.openSync fname, 'r'
  rs = Readable()
  frameBoundary = 2760

  # fs.read fd, new Buffer(6000), 0, 6000, 0, (err, bytesRead, buffer) ->
  #   v = new DataView toArrayBuffer buffer
  #   tags = parser.readTags(v)
  #   for tag in tags
  #     if tag._section.type is 'frame'
  #       frameBoundary = tag._section.offset
  #       console.log "fbound: #{frameBoundary}"

  rs._read = (s) ->
    buf = new Buffer(s)
    fs.read fd, buf, 0, s, frameBoundary, (err, bytesRead, buffer) ->

      if err
        fs.close(fd)
        self.emit 'error', er
        return

      v = new DataView toArrayBuffer buffer
      lastFrame = parser.readLastFrame(v)

      if lastFrame?
        frameBoundary += lastFrame._section.offset
        rs.push buf.slice(0, lastFrame._section.offset)
      else
        rs.push null
        
  return rs



