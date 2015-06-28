fs = require 'fs'

parser = require 'mp3-parser'

toArrayBuffer = (buffer) ->
  bufferLength = buffer.length
  uint8Array = new Uint8Array(new ArrayBuffer(bufferLength));
  for i in [0..bufferLength]
    uint8Array[i] = buffer[i]
  return uint8Array.buffer;


fd = fs.openSync './audio/Fourtet.mp3', 'r'

process.on 'exit', ->
  console.log 'done'
  fs.close(fd)

size = 16384
buf = new Buffer(size)
pos = 2760 + 16912

fs.read fd, buf, 0, size, pos, (err, bytesRead, buffer) ->

  if err
    fs.close(fd)
    self.emit 'error', er
    return

  v = new DataView toArrayBuffer buffer
  console.log "This Frame: "
  console.log parser.readFrame(v)._section

  console.log "\nLast Frame: " 
  console.log parser.readLastFrame(v)._section
