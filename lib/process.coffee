#
# Process an action (parsed from a json object).
#
# The variable 'origin' will always refer to the originating user.
# 'json' will be the json object containing the action to be processed.
#

process = {
	# Parse a json file for an action
	parse: (origin, json) ->
		# Check a json file for an action and switch on it if it's present.
		if json.action and typeof json.action is 'string'
			switch json.action
				# check against each defined action.
				when 'authenticate' then authenticate origin, json
				when 'join' then join origin, json
				when 'leave' then leave origin, json
				when 'part' then leave origin, json
				when 'msg' then message origin, json
				# Invalid action, return bad request.
				else
					ret = '{"response": 400, "error": "Bad request."}'
					console.log 'server: ' + ret
					origin.write ret

		# Otherwise there is no action, return bad json.
		else
			ret = '{"response": 400, "error": "Bad json object."}'
			console.log 'server: ' + ret
			origin.write ret

	# Authenticate a user on the server.
	authenticate: (origin, json) ->
		ret = '{"response": 100, "alert": "Authentication is not enabled at this time."}'
		console.log 'server: ' + ret
		origin.write ret

	# Log a user into a channel.
	join: (origin, json) ->
		# Check the json file for a 'room' field for what channel to join.
		if json.room and typeof json.room is 'string'
			# Confirm the Channel title includes a '#' character and error if not.
			if json.room.charAt(0) is not '#'
				ret = '{"response": 400, "error": "Channel/room title must be prefixed with '#'"}'
				console.log 'server: ' + ret
				origin.write ret

			# Otherwise go ahead and process our join command
			else
				# Disabled ATM
				ret = '{"response": 100, "alert": "Multi-user messaging is not enabled at this time."}'
				console.log 'server: ' + ret
				origin.write ret

		# If no 'room' field is given (or if our 'room' field is not a string)
		# return bad json.
		else
			ret = '{"response": 400, "error": "Bad or missing room name."}'
			console.log 'server: ' + ret
			origin write ret

	# Log a user out of a channel.
	leave: (origin, json) ->
		# Check the json file for a 'room' field for what channel to leave.
		if json.room and typeof json.room is 'string'
			# Confirm the Channel title includes a '#' character and error if not.
			if json.room.charAt(0) is not '#'
				ret = '{"response": 400, "error": "Channel/room title must be prefixed with '#'"}'
				console.log 'server: ' + ret
				origin.write ret

			# Otherwise go ahead and process our join command
			else
				# Disabled ATM
				ret = '{"response": 100, "alert": "Multi-user messaging is not enabled at this time."}'
				console.log 'server: ' + ret
				origin.write ret

		# If no 'room' field is given (or if our 'room' field is not a string)
		# return bad json.
		else
			ret = '{"response": 400, "error": "Bad or missing room name."}'
			console.log 'server: ' + ret
			origin write ret

	# Message a user or group (that the user/client is logged into)
	message: (origin, json) ->
		# Check the json file for a 'to' field for message delivery.
		if json.to and typeof json.to is 'string'
			# Check if we are sending a message to a channel/room
			if json.room.charAt(0) is '#'
				# Disabled
				ret = '{"response": 100, "alert": "Multi-user messaging is not enabled at this time."}'
				console.log 'server: ' + ret
				origin.write ret

			else
				# Disabled
				ret = '{"response": 100, "alert": "Messaging is not enabled at this time."}'
				console.log 'server: ' + ret
				origin.write ret

		# If no 'to' field is given (or if our 'to' field is not a string)
		# return bad json.
		else
			ret = '{"response": 400, "error": "Bad or missing recipient."}'
			console.log 'server: ' + ret
			origin.write ret
}

module.exports = process
