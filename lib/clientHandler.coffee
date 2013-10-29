#
# Handle client and channel lists.
#
class Channel
	constructor: (string) ->
		@channame = string
		@members = null

Array.prototype.remove = (element) ->
	for e, i in this when e is element
		return this.splice(i, 1)

clientHandler=
	clientlist = []
	chanlist = {}

	joinchan: (client, room) ->
		if !chanlist[room]
			chanlist[room] = new Channel(room)
		
		chanlist[room].members.push client
		client.chans.push room
		ret = '{"response": 200}'
		console.log 'server: ' + ret
		client.stream.write ret

	partchan: (client, room) ->
		if !chanlist[room]
			ret = '{"response": 404}'
			console.log 'server: '+ ret
			return client.stream.write ret

		chanlist[room].members.remove client
		client.chans.remove room
		ret = '{"response": 200}'
		console.log 'server: ' + ret
		client.stream.write ret

module.exports = clientHandler
