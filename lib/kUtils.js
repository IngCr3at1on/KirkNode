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


/* Each client gets created with several variables.
 * (I would like to include this in clientHandler but doing so breaks things,
 * more specifically creating a client by calling clienHandler seems to break
 * stream recognition for each client causing them to come up as undefined).
 */
exports.Client = function() {
    // Unique 8bit ID for all users
    var id = 00000000
    // Individual data stream
      , stream = undefined
    /* We build an object from multiple lines from the stream until we either
     * have a complete json object or reach the limit defined above. */
      , obj = undefined
    // Track each line as we add to the above object.
      , i = 0
    // Create clients without a name, this is re-assigned.
      , name = null
    /* Is a client authorized (logged in w/ a password), by default this is
     * false */
      , auth = false
    /* List any channels that the client is currently logged into (this is
     * used to ensure a client is logged out of all channels upon quitting). */
      , chans = []
}
