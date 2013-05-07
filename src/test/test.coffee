assert = require 'assert'
net = require 'net'

host = 'localhost'
port = 8124

describe 'JIM Socket', ->
	describe '#createServer()', ->
		it 'should return a JSON object containing a 200 ok response code', ->
			socket = net.createConnection port, host
			socket.on 'connect', (connect) ->
				connect.should.equal "{response: 200}"