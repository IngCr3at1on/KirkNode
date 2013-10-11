#
# Handle client login/logout and process received messages (json objects).
#
clients = require './clients'
jimHandler = require './jimHandler'

# Add multiline messages to an object until we have a valid json, store here
# in the interim.
obj = undefined

# Count to JSONLIMIT and error if we haven't gotten a valid json object by then
i =  0

# 500 characters is less then 7 lines at 80 characters per line.
# Assuming the opening bracket comes in on 1 line, then each entry pair on the
# following lines a single line message could be delivered in 6 lines, which
# means we need to be checking 12 lines at a time for objects (14 to be safe)
JSONLIMIT = 14

class Client
	constructor: (stream) ->
		@stream = stream
		@name = null

Array.prototype.remove = (element) ->
	for e, i in this when e is element
		return this.splice(i, 1)

KirkNode =
	init: (stream) ->
		client = new Client(stream)
		clients.list.push client

		user = 'guest' + clients.list.length
		for c in clients.list
			if c.name is user
				user = 'guest0' + clients.list.length

		client.name = user
		console.log client.name + ' connected'

		stream.write '{"response": 200}'

		stream.on 'end', ->
			clients.list.remove client
			console.log client.name + ' disconnected'

		stream.on 'data', (json) ->
			if json and typeof json is 'object'
				if KirkNode.isValidJson json
					KirkNode.ReviewJson client, json

				else if !obj
					obj = json

				else
					obj = obj + json

					if KirkNode.isValidJson obj
						KirkNode.ReviewJson client, obj

					else if i is JSONLIMIT
						# We've passed the max line size for a JIM JSON object
						# so return bad json
						ret = '{"response": 400, "error": "Bad json object."}'
						console.log 'server: ' + ret
						client.stream.write ret
						obj = undefined
						i = 0

					else i++

	isValidJson: (json) ->
		try
			JSON.parse(json)
			return true
		catch e
			return false

	ReviewJson: (client, json) ->
		console.log client.name + ': ' + json.toString()
		jimHandler.review client, json

module.exports = KirkNode
