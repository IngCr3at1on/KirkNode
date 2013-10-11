#
# Initiate our server and listen for a connection, json objects will be passed
# to the parse function in process for evaluation.
#

# TODO
#   Add port range.
#   Add IP check and black list.
#

net = require 'net'
KirkNode = require './lib/KirkNode'

PORT = 4004

server = net.createServer (stream) ->
	KirkNode.init stream

server.listen PORT, ->
  console.log 'server bound on port '+PORT
