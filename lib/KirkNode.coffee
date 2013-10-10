#
# Handle client login/logout and process received messages (json objects).
#
process = require './process'

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

KirkNode = {
	init: (client) ->

		client.on 'end', ->
			console.log 'client disconnected'

		client.on 'data', (json) ->
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
						client.write ret
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
		console.log 'client: ' + json.toString()
		process.review client, json
}

module.exports = KirkNode
