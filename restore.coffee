usage =
"""

Usage: consul-restore [consul http address]

  Copy the current directory's files and folders into consul's key value store

"""

argv = process.argv[2..]
if argv.length isnt 1
  console.error usage
  process.exit 1

consul = argv[0]
path = require 'path'
fs = require 'fs'
url = require 'url'
http = require 'http'

walk = (dir) ->
  results = []
  for file in fs.readdirSync dir
    file = "#{dir}/#{file}"
    stat = fs.statSync file
    if stat and stat.isDirectory()
      results.push
        file: "#{file}/"
        content: null
      results = results.concat walk file
    else
      results.push
        file: file
        content: fs.readFileSync file
  results

files = walk process.cwd()

for file in files
  file.key = file.file.slice process.cwd().length + 1
  do (file) ->
    params = url.parse "http://#{consul}/v1/kv/#{file.key}"
    params.method = 'PUT'
    req = http.request params, (res) ->
      if res.statusCode isnt 200
        return console.error "#{res.statusCode} #{file.key}"
      res.setEncoding 'utf8'
      res.on 'data', (chunk) ->
        console.log file.key
    req.on 'error', console.error
    req.write file.content if file.content?
    req.end()
