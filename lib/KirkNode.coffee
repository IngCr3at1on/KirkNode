#
# Handle client login/logout and process received messages (json objects).
#
process = require './process'

obj = undefined
i =  0

KirkNode = {
	init: (client) ->

		client.on 'end', ->
			console.log 'client disconnected'

		client.on 'data', (json) ->
			if json and typeof json is 'object'
				if KirkNode.isValidJson json
					console.log 'client: ' + json.toString()
					process.review client, json

				else if !obj
					obj = json

				else
					obj = obj + json

					if KirkNode.isValidJson obj
						console.log 'client: ' + obj.toString()
						process.review client, obj

					# 10 is an arbitrary number and needs to be replaced after
					# we define a more appropriate max object size.
					else if i is 10
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
}

module.exports = KirkNode
