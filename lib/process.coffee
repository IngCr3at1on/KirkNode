#
# Process an action (parsed from a json object).
#
# The variable 'client' will always refer to the originating user/client.
# 'json' will be the json object containing the action to be processed.
# 'obj' is a converted json object which we can grab our key-pairs from.
#

clients = require './clients'

process = {
	#
	# Review / parse a json file for an action
	#
	review: (client, json) ->
		# parse our json object into something we can grab variables from
		# directly
		if obj = JSON.parse(json)
			action = obj.action
		
			if action and typeof action is 'string'
				switch action
					# check against each defined action.
					when 'authenticate' then process.authenticate client, obj
					when 'join' then process.join client, obj
					when 'leave' then process.leave client, obj
					when 'part' then process.leave client, obj
					when 'msg' then process.message client, obj
					when 'quit' then process.quit client
					# Invalid action, return bad request.
					else
						ret = '{"response": 400, "error": "Bad request."}'
						console.log 'server: ' + ret
						client.stream.write ret

		# Otherwise there is no action or the JSON object is malformed,
		# return bad json.
		else
			ret = '{"response": 400, "error": "Bad json object."}'
			console.log 'server: ' + ret
			client.stream.write ret

	#
	# Authenticate a user on the server.
	#
	authenticate: (client, obj) ->
		ret = '{"response": 100, "alert": "Authentication is not enabled at this time."}'
		console.log 'server: ' + ret
		client.stream.write ret

	#
	# Log a user into a channel.
	#
	join: (client, obj) ->
		# Check the obj file for a 'room' field for what channel to join.
		if obj.room and typeof obj.room is 'string'
			# Confirm the Channel title includes a '#' character and error if not.
			if obj.room.charAt(0) is not '#'
				ret = '{"response": 400, "error": "Channel/room title must be prefixed with '#'"}'
				console.log 'server: ' + ret
				client.stream.write ret

			# Otherwise go ahead and process our join command
			else
				# Disabled ATM
				ret = '{"response": 100, "alert": "Multi-user messaging is not enabled at this time."}'
				console.log 'server: ' + ret
				client.stream.write ret

		# If no 'room' field is given (or if our 'room' field is not a string)
		# return bad json.
		else
			ret = '{"response": 400, "error": "Bad or missing room name."}'
			console.log 'server: ' + ret
			client.stream.write ret

	#
	# Log a user out of a channel.
	#
	leave: (client, obj) ->
		# Check the obj file for a 'room' field for what channel to leave.
		if json.room and typeof obj.room is 'string'
			# Confirm the Channel title includes a '#' character and error if not.
			if obj.room.charAt(0) is not '#'
				ret = '{"response": 400, "error": "Channel/room title must be prefixed with '#'"}'
				console.log 'server: ' + ret
				client.stream.write ret

			# Otherwise go ahead and process our join command
			else
				# Disabled ATM
				ret = '{"response": 100, "alert": "Multi-user messaging is not enabled at this time."}'
				console.log 'server: ' + ret
				client.stream.write ret

		# If no 'room' field is given (or if our 'room' field is not a string)
		# return bad json.
		else
			ret = '{"response": 400, "error": "Bad or missing room name."}'
			console.log 'server: ' + ret
			client.stream.write ret

	#
	# Message a user or group (that the user/client is logged into)
	#
	message: (client, obj) ->
		# Check the obj file for a 'to' field for message delivery.
		if obj.to and typeof obj.to is 'string'
			# Check if we are sending a message to a channel/room
			if json.to.charAt(0) is '#'
				# Disabled
				ret = '{"response": 100, "alert": "Multi-user messaging is not enabled at this time."}'
				console.log 'server: ' + ret
				client.stream.write ret

			else
				# Disabled
				ret = '{"response": 100, "alert": "Messaging is not enabled at this time."}'
				console.log 'server: ' + ret
				client.stream.write ret

		# If no 'to' field is given (or if our 'to' field is not a string)
		# return bad json.
		else
			ret = '{"response": 400, "error": "Bad or missing recipient."}'
			console.log 'server: ' + ret
			client.stream.write ret

	#
	# Quit / Log a client out of the server
	#
	quit: (client) ->
		client.stream.end()
}

module.exports = process
