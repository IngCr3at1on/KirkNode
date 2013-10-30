################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2013, Nathan Bass
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
################################################################################

#
# Process an action (parsed from a json object).
#
# The variable 'client' will always refer to the originating user/client.
# 'json' will be the json object containing the action to be processed.
# 'obj' is a converted json object which we can grab our key-pairs from.
#
clientHandler = require './clientHandler'

jimHandler =
	#
	# Review / parse a json file for an action
	#
	review: (client, json) ->
		# parse our json object into something we can grab variables from
		# directly
		if obj = JSON.parse(json)
			# Grab the action from our JSON object.
			action = obj.action
			# Confirm the action is valid before processing it.
			if action and typeof action is 'string'
				# If the action is valid run through the possible actions.
				switch action
					# check against each defined action.
					when 'authenticate' then jimHandler.authenticate client, obj
					when 'join' then jimHandler.join client, obj
					when 'leave' then jimHandler.leave client, obj
					when 'part' then jimHandler.leave client, obj
					when 'msg' then jimHandler.message client, obj, json
					when 'quit' then jimHandler.quit client
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
				clientHandler.joinchan client, obj.room

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
		if obj.room and typeof obj.room is 'string'
			# Confirm the Channel title includes a '#' character and error if not.
			if obj.room.charAt(0) is not '#'
				ret = '{"response": 400, "error": "Channel/room title must be prefixed with '#'"}'
				console.log 'server: ' + ret
				client.stream.write ret

			# Otherwise go ahead and process our part command
			else
				clientHandler.partchan client, obj.room, true

		# If no 'room' field is given (or if our 'room' field is not a string)
		# return bad json.
		else
			ret = '{"response": 400, "error": "Bad or missing room name."}'
			console.log 'server: ' + ret
			client.stream.write ret

	#
	# Message a user or group (that the user/client is logged into)
	#
	message: (client, obj, json) ->
		# Check the obj file for a 'to' field for message delivery.
		if obj.to and typeof obj.to is 'string'
			# Check if we are sending a message to a channel/room
			if obj.to.charAt(0) is '#'
				clientHandler.handleroommsg client, obj.to, json

			else
				clientHandler.handleprivmsg client, obj.to, json

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

module.exports = jimHandler
