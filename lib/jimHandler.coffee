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
authHandler = require './authHandler'
clientHandler = require './clientHandler'
kLog = require './kLog'
kResponse = require './kResponse'
lists = require './lists'

jimHandler =
	##
	## Main external function, nothing else should ever need to be called from
	## any other file/location.
	##

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
					# Check against each defined action:
					# Handle standard JIM requests first.
					when 'authenticate' then jimHandler.authenticate client, obj
					when 'join' then jimHandler.join client, obj
					when 'leave' then jimHandler.leave client, obj
					when 'part' then jimHandler.leave client, obj
					when 'msg' then jimHandler.message client, obj, json
					when 'quit' then jimHandler.quit client
					# The action isn't a standard JIM request but may still be
					# specific to KirkNode itself.
					when 'list' then jimHandler.list client, obj					
					# Invalid action, return bad request.
					else
						kResponse.send '{"response": 400, "error": "Bad request."}'

		# Otherwise there is no action or the JSON object is malformed,
		# return bad json.
		else
			kResponse.send client '{"response": 400, "error": "Bad json object."}'

	##
	## Internal/private functions, should not be called from other
	## files/locations.
	##

	##
	## Handle standard JIM requests first.
	##

	#
	# Authenticate a user on the server.
	#
	authenticate: (client, obj) ->
		authHandler.authenticate client, obj

	#
	# Log a user into a channel.
	#
	join: (client, obj) ->
		# Check the obj file for a 'room' field for what channel to join.
		if obj.room and typeof obj.room is 'string'
			# Confirm the Channel title includes a '#' character and error if not.
			if obj.room.charAt(0) is not '#'
				kResponse.send client '{"response": 400, "error": "Channel/room title must be prefixed with '#'"}'

			# Otherwise go ahead and process our join command
			else
				clientHandler.joinchan client, obj.room

		# If no 'room' field is given (or if our 'room' field is not a string)
		# return bad json.
		else
			kResponse.send client '{"response": 400, "error": "Bad or missing room name."}'

	#
	# Log a user out of a channel.
	#
	leave: (client, obj) ->
		# Check the obj file for a 'room' field for what channel to leave.
		if obj.room and typeof obj.room is 'string'
			# Confirm the Channel title includes a '#' character and error if not.
			if obj.room.charAt(0) is not '#'
				kResponse.send client '{"response": 400, "error": "Channel/room title must be prefixed with '#'"}'

			# Otherwise go ahead and process our part command
			else
				clientHandler.partchan client, obj.room, true

		# If no 'room' field is given (or if our 'room' field is not a string)
		# return bad json.
		else
			kReponse.send client '{"response": 400, "error": "Bad or missing room name."}'

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
			kResponse.send client '{"response": 400, "error": "Bad or missing recipient."}'

	#
	# Quit / Log a client out of the server
	#
	quit: (client) ->
		client.stream.end()

	##
	## Handle KirkNode functionality not specific to JIM.
	##

	#
	# Call for list command to list all users or rooms on the servers, accepts
	# multiple commands for listing rooms and/or users.
	#
	list: (client, obj) ->
		# Check the obj file for a 'group' field which will be used to determine
		# whether to list users, rooms or both.
		if obj.group and typeof obj.group is 'string'
			# Set group from obj.group for reference.
			group = obj.group
			# Check group for users or room listing.
			switch group
				when 'group' is 'users'
					# Need to add this method, for now list all so's not to 
					# error.
					jimHandler.listall
				when 'group' is 'rooms'
					# Need to add this method, for now list all so's not to 
					# error.
					jimHandler.listall
				# This should not occur.
				else jimHandler.listall
		# If there is no group field just list all.
		else jimHandler.listall

	#
	# List all users and rooms on the server, starting w/ rooms.
	#
	listall: (client, obj) ->
		# List rooms first, (this should be moved to it's own method.)
		for c in lists.chan
			chans = c+',\n'
		# and list users. (should also be moved to a separate method.)
		for u in lists.client
			users = u+',\n'

		# Form our lists so we can parse them into JSON.
		alert = "'Channels:'+chans+'Users:'+users'"
		# This is information being returned from the server to the client, use
		# response code 100 and a standard alert for this.
		kResponse.send client '{"response": 100, "alert": alert}'

module.exports = jimHandler
