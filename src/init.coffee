net = require 'net'
process = require './process'

server = net.createServer (client) ->
	console.log 'client connected'
	client.write "{response: 200}"

	client.on 'end', ->
		console.log 'client disconnected'
	
	client.on 'data', (json) ->
	    process.parse client, json
		console.log json.toString()

# TODO
#   Add port range.
#
server.listen 4004, ->
  console.log 'server bound'
