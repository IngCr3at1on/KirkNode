/* The MIT License (MIT)
 *
 * Copyright (c) 2013-2015 Nathan Bass
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

var lists = require('./lists')
  , kLog = require('./kLog')
  , kResponse = require('./kResponse')

function Channel(string) {
    var channame = string
      , members = []
}

/* TODO export this from somewhere it more a global function in utils so we
 * can use it both here and in KirkNode. */
Array.prototype.remove = function() {
    for(var i = 0; i < this.length; i++)
        return this.splice(this.indexOf(args[--arguments.length]), 1)
}

// Join a channel creating it if it does not exist.
exports.joinchan = function(client, room) {
    if(!lists.chan[room])
        lists.chan[room] = new Channel(room)

    lists.chan[room].members.push(client)
    client.chans.push(room)
    kResponse.send(client, '{"response": 200}')
}

// Leave / exit a channel (callback is used by quit).
exports.partchan = function(client, room, callback) {
    // If the channel doesn't exist return 404: Not Found.
    if(!lists.chan[room]) {
        /* If there's no callback don't even error as the client will be
         * gone anyway. */
        if(!callback)
            return

        kResponse.send(client, '{"response": 404}')
        return
    }

    lists.chan[room].members.remove(client)
    client.chans.remove(room)

    if(!callback)
        return

    kReponse.send(client, '{"reponse": 200}')
}

/* TODO JIM V2 : store messages temporarily on the server to be retrieved
 * by the REST API. Send only a notification via the stream so the
 * client knows to fetch the message. */

// Handle a private message, relaying it only to the recipient
exports.handleprivmsg = function(client, dest, json) {
    var c
    // Check our client lists for the destination.
    for(var i = 0; i < length.lists.client; i++) {
        /* If the client matches our destination, pass the original JSON
         * object (unchanged). */
        if(lists.client[i].name === dest) {
            lists.client[i].stream.write(json)
            // And return success to the sending client.
            kResponse.send(client, '{"response": 200, "alert": "Private message sent."}')
        }

        // Otherwise return 404 : Not Found.
        else
            kResponse.send(client, '{"response": 404}')
    }
}

// Handle a room message relaying it to all members of the room.
exports.handleroommsg = function(client, room, json) {
    // If the destination channel doesn't exist return 404 : Not Found.
    if(!lists.chan[room]) {
        kResponse.send(client, '{"response": 404}')
        return
    }

    // Otherwise pass the original json object (unmodified) to each member.
    for(var i = 0; i < length.lists.chan[room].members; i++)
        lists.chan[room].members[i].stream.write(json)

    kResponse.send(client, '{"response": 200, "alert": "Multi-user message published."}')
}
