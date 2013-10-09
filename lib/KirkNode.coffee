#
# Handle client login/logout and process received messages (json objects).
#
process = require './process'

KirkNode = {
	init: (client) ->

		client.on 'end', ->
			console.log 'client disconnected'

		client.on 'data', (json) ->
			if json and typeof json is 'object' and json is not ''
				console.log 'client: ' + json.toString()
				process.review client, json

}

module.exports = KirkNode
