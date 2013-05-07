net = require 'net'

server = net.createServer (client) ->
	console.log 'client connected'
	client.write "{response: 200}"

	client.on 'end', ->
		console.log 'client disconnected'
	
	client.on 'data', (json) ->
		client.write json
		console.log json.toString()

server.listen 8124, ->
  console.log 'server bound'