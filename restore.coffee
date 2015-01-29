usage =
"""

Usage: consul-restore [consul http address]

  Copy the current directory's files and folders into consul's key value store

"""

argv = process.argv[2..]
if argv.length isnt 1
  console.error usage
  process.exit 1