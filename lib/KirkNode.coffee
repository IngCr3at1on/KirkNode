#
# Handle client login/logout and process received messages (json objects).
#
process = require './process'

KirkNode = {
	init: (client) ->

		client.on 'end', ->
			console.log 'client disconnected'

		client.on 'data', (json) ->
			if json
				console.log json.toString()
				process.parse client, json

}

module.exports = KirkNode
