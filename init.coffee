#
# Initiate our server and send all stream data to KirkNode.
#
KirkNode = require './lib/KirkNode'
net = require 'net'

# TODO
#   Add port range.
#   Add IP check and black list.
#

PORT = 4004

server = net.createServer (stream) ->
	KirkNode.init stream

server.listen PORT, ->
	console.log 'server bound on port '+PORT
