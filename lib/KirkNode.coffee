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
				if KirkNode.isValidJson json
					console.log 'client: ' + json.toString()
					process.review client, json

				# So the problem here is obj is always undefined as it's lost
				# with each new line, I tried defining object earlier and it
				# caused some errors.
				#
				# I'm not sure how this is going to work without first tracking
				# a difference between clients otherwise messages might get
				# mixed up by the socket.
				else if !obj
					obj = json

				else
					obj = obj + json

					if KirkNode.isValidJson json
						console.log 'client: ' + obj.toString()
						process.review client, obj

					else if !i
						i = 0

					# 10 is an arbitrary number and needs to be replaced after
					# we define a more appropriate max object size.
					else if i is 10
						# We've passed the max line size for a JIM JSON object
						# so return bad json
						ret = '{"response": 400, "error": "Bad json object."}'
						console.log 'server: ' + ret
						origin.write ret
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
