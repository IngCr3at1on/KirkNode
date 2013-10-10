#
# Process an action (parsed from a json object).
#
# The variable 'origin' will always refer to the originating user.
# 'json' will be the json object containing the action to be processed (the
# object is converted to a javascript object during the review function).
#

process = {
	#
	# Review / parse a json file for an action
	#
	review: (origin, json) ->
		# parse our json object into something we can grab variables from
		# directly
		if json is JSON
			obj =  JSON.parse(json)
			action = obj.action
		
			if action and typeof action is 'string'
				switch action
					# check against each defined action.
					when 'authenticate' then process.authenticate origin, obj
					when 'join' then process.join origin, obj
					when 'leave' then process.leave origin, obj
					when 'part' then process.leave origin, obj
					when 'msg' then process.message origin, obj
					# Invalid action, return bad request.
					else
						ret = '{"response": 400, "error": "Bad request."}'
						console.log 'server: ' + ret
						origin.write ret

		# Otherwise there is no action or the JSON object is malformed,
		# return bad json.
		else
			ret = '{"response": 400, "error": "Bad json object."}'
			console.log 'server: ' + ret
			origin.write ret

	#
	# Authenticate a user on the server.
	#
	authenticate: (origin, obj) ->
		ret = '{"response": 100, "alert": "Authentication is not enabled at this time."}'
		console.log 'server: ' + ret
		origin.write ret

	#
	# Log a user into a channel.
	#
	join: (origin, obj) ->
		# Check the obj file for a 'room' field for what channel to join.
		if obj.room and typeof obj.room is 'string'
			# Confirm the Channel title includes a '#' character and error if not.
			if obj.room.charAt(0) is not '#'
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

	#
	# Log a user out of a channel.
	#
	leave: (origin, obj) ->
		# Check the obj file for a 'room' field for what channel to leave.
		if json.room and typeof obj.room is 'string'
			# Confirm the Channel title includes a '#' character and error if not.
			if obj.room.charAt(0) is not '#'
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

	#
	# Message a user or group (that the user/client is logged into)
	#
	message: (origin, obj) ->
		# Check the obj file for a 'to' field for message delivery.
		if obj.to and typeof obj.to is 'string'
			# Check if we are sending a message to a channel/room
			if json.to.charAt(0) is '#'
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
