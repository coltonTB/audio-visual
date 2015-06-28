mp3Stream = require './mp3Stream'
lame = require('lame')
parser = require 'mp3-parser'
toArrayBuffer = (buffer) ->
  bufferLength = buffer.length
  uint8Array = new Uint8Array(new ArrayBuffer(bufferLength));
  for i in [0..bufferLength]
    uint8Array[i] = buffer[i]
  return uint8Array.buffer;


mp3Stream('./audio/Fourtet.mp3')
  .on 'data', (dat) ->
    v = new DataView toArrayBuffer dat
    console.log parser.readFrame(v)._section



