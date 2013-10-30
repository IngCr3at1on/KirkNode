#
# Handle client login/logout and process received messages (json objects).
#
clientHandler = require './clientHandler'
jimHandler = require './jimHandler'

# 500 characters is less then 7 lines at 80 characters per line.
# Assuming the opening bracket comes in on 1 line, then each entry pair on the
# following lines a single line message could be delivered in 6 lines, which
# means we need to be checking 12 lines at a time for objects (14 to be safe)
JSONLIMIT = 14

#
# Each client gets created with several variables.
#
class Client
	constructor: (stream) ->
		# Individual data stream
		@stream = stream
		# We build an object from multiple lines from the stream until we either
		# have a complete json object or reach the limit defined above.
		@obj = undefined
		# Track each line as we add to the above object.
		@i = 0
		# Create clients without a name, this is re-assigned.
		@name = null
		# Is a client authorized (logged in w/ a password), by default this is
		# false.
		@auth = false
		# List any channels that the client is currently logged into (this is
		# used to ensure a client is logged out of all channels upon quitting).
		@chans = []

#
# List all connected clients.
#
clientlist = []

#
# Remove an element from an array, this is also being used in clientHandler,
# it would be nice to export it from somewhere for both but I'm having issues
# with this.
#
Array.prototype.remove = (element) ->
	for e, i in this when e is element
		return this.splice(i, 1)

#
# Main application, handles client connections, default name generation and
# JSON confirmation / parsing; parsed objects are then passed to the jimHandler.
#
KirkNode =
	init: (stream) ->
		# Create a new client and add them to the clients list
		client = new Client(stream)
		clientlist.push client

		# Give each client a guestID on login (changed on authorization).
		user = 'guest' + clientlist.length
		# The above isn't the greatest numberic assignment, this should keep us
		# from getting repeat guestIDs (I would like to replace this code).
		for c in clientlist
			if c.name is user
				user = 'guest0' + clientlist.length

		# Set the name in the client object for later reference and log connect.
		client.name = user
		console.log client.name + ' connected'
		# Send ack to client to confirm connect.
		stream.write '{"response": 200}'

		# Process a disconnect (called by quit).
		stream.on 'end', ->
			# Confirm a client is logged out of all channels.
			for c in client.chans
				clientHandler.partchan client, c, false

			console.log client.name + ' disconnected'

		# Receive data and assemble a json object.
		stream.on 'data', (json) ->
			if json and typeof json is 'object'
				# Check the data coming off the stream and if it is a valid
				# JSON object already go ahead and send it to the jimHandler for
				# review.
				if KirkNode.isValidJson json
					KirkNode.ReviewJson client, json

				# Otherwise check if the client has an incomplete object defined
				# for large/multiline objects. If not, create one with the last
				# input line.
				else if !client.obj
					client.obj = json

				# If the client does have an incomplete object defined add to it
				# instead and check if it's valid.
				else
					client.obj = client.obj + json

					if KirkNode.isValidJson client.obj
						KirkNode.ReviewJson client, client.obj
						client.obj = undefined
						client.i = 0

					# If the object is still not valid check if we have passed
					# our line limit and return bad JSON (destroying our
					# incomplete JSON object).
					else if client.i is JSONLIMIT
						# We've passed the max line size for a JIM JSON object
						# so return bad json
						ret = '{"response": 400, "error": "Bad json object."}'
						console.log 'server: ' + ret
						client.stream.write ret
						obj = undefined
						client.i = 0

					# If we haven't passed our line limit, iterate that count.
					else client.i++

	# Check if a JSON file is valid.
	isValidJson: (json) ->
		try
			JSON.parse(json)
			return true
		catch e
			return false

	# Log a JSON object to console before sending it to the jimHandler.
	ReviewJson: (client, json) ->
		console.log client.name + ': ' + json.toString()
		jimHandler.review client, json

module.exports = KirkNode
