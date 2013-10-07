#
# Initiate our server and listen for a connection, json objects will be passed
# to the parse function in process for evaluation.
#

# TODO
#   Add port range.
#   Add IP check and black list.
#

net = require 'net'
process = require './process'

PORT = 4004

server = net.createServer (client) ->
	console.log 'client connected'
	client.write "{response: 200}"

	client.on 'end', ->
		console.log 'client disconnected'
	
	client.on 'data', (json) ->
		if json
			process.parse client, json
			console.log json.toString()

server.listen PORT, ->
  console.log 'server bound on port '+PORT
