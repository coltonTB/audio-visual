fs = require 'fs'
Readable = require('stream').Readable

module.exports = (fname) ->
  fd = fs.openSync './audio/Fourtet.mp3', 'r'
  pos = 0
  totalRead = 0
  rs = Readable()

  rs._read = (s) ->
    buf = new Buffer(s)

    fs.read fd, buf, 0, s, pos, (err, bytesRead, buffer) ->

      if err
        fs.close(fd)
        self.emit 'error', er
        return

      # find latest mp3 header boundary
      f_count = 0
      boundary = null
      i=0; while i < bytesRead
        i+=1
        twoBytes = buffer.readUInt8(bytesRead-i)
        firstByte =  twoBytes & 0x0F
        secondByte = (twoBytes & 0xF0) >> 4

        if firstByte == 15 and secondByte == 15
          f_count += 2
        else if firstByte == 15
          f_count += 1
        else if secondByte == 15
          f_count = 1
        else
          f_count = 0

        if f_count >= 2
          # console.log "\nfound fff at #{2*i} bytes from end"
          boundary = bytesRead - (2*i)
          break

      # console.log "\nbytes read: #{bytesRead}"
      # console.log   "total leng: #{boundary}"

      rs.push buffer.slice(0, boundary)
      pos += boundary

  return rs







