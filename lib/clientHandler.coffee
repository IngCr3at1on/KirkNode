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
# Handle client and channel lists.
#
clients = require './clients'

#
# Each channel is built of a name and an array of members.
#
class Channel
	constructor: (string) ->
		@channame = string
		@members = []

#
# Remove an element from an array, this is also being used in KirkNode, it
# would be nice to export it from somewhere for both but I'm having issues
# with this.
#
Array.prototype.remove = (element) ->
	for e, i in this when e is element
		return this.splice(i, 1)

#
# List all current channels.
#
chanlist = new Object()

#
# Handle client/channel functions (joining, parting).
#
clientHandler=
	# Join a channel creating it if it does not exist.
	joinchan: (client, room) ->
		if !chanlist[room]
			chanlist[room] = new Channel(room)
		
		chanlist[room].members.push client
		client.chans.push room
		ret = '{"response": 200}'
		console.log 'server: ' + ret
		client.stream.write ret

	# Leave / exit a channel (callback is used by quit).
	partchan: (client, room, callback) ->
		# If the channel doesn't exist return 404 : Not Found.
		if !chanlist[room]
			# If there's no callback don't even error as the client will be
			# gone anyway.
			if !callback
				return

			ret = '{"response": 404}'
			console.log 'server: '+ ret
			client.stream.write ret
			return

		chanlist[room].members.remove client
		client.chans.remove room

		if !callback
			return

		ret = '{"response": 200}'
		console.log 'server: ' + ret
		client.stream.write ret

	# Handle a private message, relaying it only to the recipient.
	handleprivmsg: (client, dest, json) ->
		# Check our client list for the destination.
		for c in clients.list
			# If the client matches are destination, pass the original JSON
			# object (unchanged).
			if c.name is dest
				c.stream.write json
				# And return success to the sending client.
				ret = '{"response": 200, "alert": "Private message sent."}'
				console.log 'server: ' + ret
				client.stream.write ret

			# Otherwise return 404 : Not Found.
			else
				ret = '{"response": 404}'
				console.log 'server: '+ ret
				client.stream.write ret

	# Handle a room message relaying it to all members of the room.
	handleroommsg: (client, room, json) ->
		# If the destination channel doesn't exist return 404 : Not Found.
		if !chanlist[room]
			ret = '{"response": 404}'
			console.log 'server: '+ ret
			client.stream.write ret
			return

		# Otherwise pass the original json object (unmodified) to each member.
		for m in chanlist[room].members
			m.stream.write json

		# Return success to the sending client.
		ret = '{"response": 200, "alert": "Multi-user message published."}'
		console.log 'server: ' + ret
		client.stream.write ret

module.exports = clientHandler
