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

var DEBUG = 0
  , LOGFILE = './logs/log'
  , ERRFILE = './logs/err'


// Print a log and if debugging is enabled log it to a file.
exports.print = function(data) {
    var ret = 'server: '+data
    if(DEBUG === 1)
        // Not enabled yet
        console.log(ret)
    else
        console.log(ret)
}

// Print error to console and if debugging is enabled log it to a file.
exports.err = function(data) {
    var ret = 'err: '+ data
    if(DEBUG === 1)
        // Not enabled yet
        console.log(ret)
    else
        console.log(ret)
}
