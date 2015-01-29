usage =
"""

Usage: consul-backup [consul http address]

  Copy the contents of consul's key value store into files and folders

"""

argv = process.argv[2..]
if argv.length isnt 1
  console.error usage
  process.exit 1

path = require 'path'
fs = require 'fs'
mkdirp = require 'mkdirp'
http = require 'http'

get = (url, cb) ->
http
  .get url, (res) ->
    data = ''
    res.setEncoding 'utf8'
    res.on 'data', (chunk) -> data += chunk
    res.on 'end', ->
      data = JSON.parse data
      cb null, data
  .on 'error', (err) ->
    

get 'http://10.1.1.156:8500/v1/kv/?recurse', (err, keys) ->
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

