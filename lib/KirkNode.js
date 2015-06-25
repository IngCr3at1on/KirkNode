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
  , clientHandler = require('./clientHandler')
  , jimHandler = require('./jimHandler')
  , kLog = require('./kLog')
  , kResponse = require('./kResponse')
  , kUtils = require('./kUtils')

/* 500 characters is less then 7 lines at 80 characters per line.
 * Assuming the opening bracket comes in on 1 line, then each entry pair on the
 * following lines a single line message could be delivered in 6 lines, which
 * means we need to be checking 12 lines at a time for objects (14 to be safe)
 */
var JSONLIMIT = 14

/* TODO export this from somewhere it more a global function in utils so we
 * can use it both here and in clientHandler. */
Array.prototype.remove = function() {
    for(var i = 0; i < this.length; i++)
        return this.splice(this.indexOf(args[--arguments.length]), 1)
}

// Check if a JSON file is valid.
function isValidJson(json) {
    try {
        JSON.parse(json)
        return true
    } catch(e) {
        return false
    }
}

// Log a JSON object to console before sending it to the jimHandler.
function ReviewJson(client, json) {
    kLog.print(client.name + ': ' + json.toString())
    jimHandler.review(client, json)
}

exports.init = function(stream) {
    // Create a new client and add them to the clients list.
    var client = new kUtils.Client(stream)
    lists.client.push(client)

    /* Assign all clients a unique 8bit ID for server reference, this will not
     * change while the client is connected regardless of name change. */
    var id = 00000000
    for(var i = 0; i < lists.client.length; i++)
        ++id

    client.id = id

    /* Give each client a guestID on login (changed on authorization).
     * id will be truncated upon connect. */
    client.name = 'guest'+id

    kLog.print(client.name + ' connected')
    // Send ack to client to confirm connect.
    stream.write('{"response": 200}')

    // Process a disconnect (called by quit).
    stream.on('end', function() {
        // Confirm a client is logged out of all channels.
        for(c in client.chans)
            clientHandler.partchan(client, c, false)

        kLog.print(client.name + ' disconnected')
    })

    // Receive data and assemble a json object.
    stream.on('data', function(json) {
        if(json && typeof(json) === 'object') {
            /* Check the data coming off the stream and if it is a valid JSON
             * object already go ahead and send it to the jimHandler for review.
             */
            if(isValidJson(json))
                ReviewJson(client, json)

            /* Otherwise check if the client has an incomplete object defined
             * for large/multiline objects. If not, create one with the last
             * input line. */
            else if(!client.obj)
                client.obj = json

            /* If the client does have an incomplete object defined add to it
             * instead and check if it's valid. */
            else {
                client.obj = client.obj + json

                if(isValidJson(client.obj)) {
                    ReviewJson(client, client.obj)
                    client.obj = undefined
                    client.i = 0
                }

                /* If the object is still not valid check if we have passed out
                 * line limit and return bad JSON (destroying our incomplete
                 * JSON object). */
                else if(client.i === JSONLIMIT) {
                    /* We've passed the max line size for a JIM JSON object so
                     * return bad json. */
                    kResponse.send(client, '{"response": 400, "error": "Bad json object."}')
                    client.obj = undefined
                    client.i = 0
                }

                // If we haven't passed our line limit, iterate that count.
                else client.i++
            }
        }
    })
}
