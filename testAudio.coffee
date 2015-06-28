fs = require 'fs'
lame = require('lame');
Speaker = require('speaker');
parser = require 'mp3-parser'

toArrayBuffer = (buffer) ->
  bufferLength = buffer.length
  uint8Array = new Uint8Array(new ArrayBuffer(bufferLength));

  for i in [0..bufferLength]
    uint8Array[i] = buffer[i]

  return uint8Array.buffer;


fs.createReadStream('./audio/Caribou-Sun.mp3')
  # .on('format', console.log)
  .on('data', (dat) ->
    v = new DataView toArrayBuffer dat
    console.log dat.length
    console.log parser.readLastFrame(v)
    console.log '\n--------\n'
  )
  .pipe(new lame.Decoder)
  .pipe(new Speaker);