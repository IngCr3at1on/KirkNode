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

/*
 * Process an action (parsed from a json object).
 *
 * The variable 'client' will always refer to the originating user/client.
 * 'json' will be the json object contatining the action to be processed.
 * 'obj' is a converted json object which we can grab our key-pairs from.
 */

var clientHandler = require('./clientHandler')
  , kLog = require('./kLog')
  , kResponse = require('./kResponse')
  , lists = require('./lists')

// Handle standard JIM requests first.

// Log a user into a channel
function join(client, obj) {
    // Check the obj for a 'room' field for what channel to join.
    if(obj.room && obj.room.typeof === 'string') {
        // Confirm the Channel title includes a '#' character and error if not.
        if(obj.room.charAt(0) !== '#')
            kResponse.send(client, '{"response": 400, "error": "Channel/room title must be prefixed with \'#\'"}')

        // Otherwise go ahead and process the join command
        else
            clientHandler.joinchan(client, obj.room)
    }

    /* If no 'room' field is given (or if our 'room' field is not a string)
     * return bad json. */
    else
        kResponse.send(client, '{"response": 400, "error": "Bad or missing room name."}')
}

// Log a user out of a channel
function leave(client, obj) {
    // Check the obj for a 'room' field for what channel to leave.
    if(obj.room && typeof(obj.room) === 'string') {
        // Confirm the Channel title includes a '#' character and error if not.
        if(obj.room.charAt(0) !== '#')
            kResponse.send(client, '{"response": 400, "error": "Channel/room title must be prefixed with \'#\'"}')

        // Otherwise go ahead and process our part command
        else
            clientHandler.partchan(client, obj.room, true)
    }

    /* If no 'room' field is given (or if our 'room' field is not a string)
     * return bad json. */
    else
        kResponse.send(client, '{"response": 400, "error": "Bad or missing room name."}')
}

// Message a user or group (that the user/client is logged into)
function message(client, obj, json) {
    // Check the obj for a 'to' field for message delivery
    if(obj.to && typeof(obj.to) === 'string') {
        // Check if we are sending a message to a channel/room
        if(obj.to.charAt(0) === '#')
            clientHandler.handleroommsg(client, obj.to, json)
        else
            clientHandler.handleprivmsg(client, obj.to, json)
    }

    /* If no 'to' field is given (or if our 'to' field is not a string)
     * return bad json. */
    else
        kResponse.send(client, '{"response": 400, "error": "Bad or missing recipient."}')
}

// Quit / Log a client out of the server
// TODO JIM v2 : End a session stream but remain logged into channels
function quit(client) {
    /* This is broken... Not sure why, needs to be resolved.
    for(var i = 0; i < client.chans.length; i++)
        clientHandler.partchan(client, client.chans[i], false)
    */

    client.stream.end()
}

// Handle KirkNode functionality not specific to JIM.

// TODO write list functions

// Review / parse a json file for an action
exports.review = function(client, json) {
    /* Parase our json object into something we can grab variables from
     * directly */
    var obj
    if(obj = JSON.parse(json)) {
        // Grab the action from our JSON object.
        action = obj.action
        // Confirm the action is valid before processing it.
        if(action && typeof(action) === 'string') {
            /* Check against each defined action, handling standard JIM,
             * requests first. */
            switch(action) {
                case 'join':
                    join(client, obj)
                    break
                case 'leave':
                case 'part':
                    leave(client, obj)
                    break
                case 'msg':
                    message(client, obj, json)
                    break
                case 'quit':
                    quit(client)
                    break
                // Kirknode specific functions.

                // Invalid action, return bad request
                default:
                    kReponse.send('{"response": 400, "error": "bad request."}')
                    break
            }
        }
    }

    /* Otherwise there is no action or the JSON object is malformed.
     * Return bad json. */
    else
        kResponse.send(client, '{"response": 400, "error": "Bad json object."}')
}
