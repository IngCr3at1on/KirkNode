#
# Handle client and channel lists.
#

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

module.exports = clientHandler
