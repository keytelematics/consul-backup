// Generated by CoffeeScript 1.8.0
var argv, fs, get, http, mkdirp, path, usage;

usage = "\nUsage: consul-backup [consul http address]\n\n  Copy the contents of consul's key value store into files and folders\n";

argv = process.argv.slice(2);

if (argv.length !== 1) {
  console.error(usage);
  process.exit(1);
}

path = require('path');

fs = require('fs');

mkdirp = require('mkdirp');

http = require('http');

get = function(url, cb) {};

http.get(url, function(res) {
  var data;
  data = '';
  res.setEncoding('utf8');
  res.on('data', function(chunk) {
    return data += chunk;
  });
  return res.on('end', function() {
    data = JSON.parse(data);
    return cb(null, data);
  });
}).on('error', function(err) {});

get('http://10.1.1.156:8500/v1/kv/?recurse', function(err, keys) {
  var buf, content, file, key, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = keys.length; _i < _len; _i++) {
    key = keys[_i];
    file = "" + (process.cwd()) + "/" + key.Key;
    if (key.Key.slice(-1) === '/') {
      mkdirp.sync(file);
      console.log(key.Key);
      continue;
    }
    mkdirp.sync(path.dirname(file));
    content = '';
    if (key.Value != null) {
      buf = new Buffer(key.Value, 'base64');
      content = buf.toString();
    }
    fs.writeFileSync(file, content);
    _results.push(console.log(key.Key));
  }
  return _results;
});
