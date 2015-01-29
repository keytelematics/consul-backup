usage =
"""

Usage: consul-backup [consul http address]

  Copy the contents of consul's key value store into files and folders

"""

argv = process.argv[2..]
if argv.length isnt 1
  console.error usage
  process.exit 1

consul = argv[0]
path = require 'path'
fs = require 'fs'
mkdirp = require 'mkdirp'
http = require 'http'

http
  .get "http://#{consul}/v1/kv/?recurse", (res) ->
    keys = ''
    res.setEncoding 'utf8'
    res.on 'data', (chunk) -> keys += chunk
    res.on 'end', ->
      keys = JSON.parse keys
      for key in keys
        file = "#{process.cwd()}/#{key.Key}"
        if key.Key.slice(-1) is '/'
          mkdirp.sync file
          console.log key.Key
          continue
        mkdirp.sync path.dirname file
        content = ''
        if key.Value?
          buf = new Buffer key.Value, 'base64'
          content = buf.toString()
        fs.writeFileSync file, content
        console.log key.Key
  .on 'error', console.error
