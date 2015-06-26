fs = require 'fs'
lame = require('lame');
Speaker = require('speaker');

fs.createReadStream('./audio/Fourtet.mp3')
  .pipe(new lame.Decoder)
  .on('format', console.log)
  .pipe(new Speaker);