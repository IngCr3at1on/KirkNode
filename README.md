KirkNode is a node.js server to implement and test the [JIM protocol](https://jim.hackpad.com)

Originally written in coffeescript, the joke was to name it "node.JIM"; being
boring that was replaced with KirkNode

Requirements:

	npm
	node.js

To get started with KirkNode run the following after cloning:

	npm install
	npm start

Install only needs to be ran the first time and only if coffee-script is not
installed on the system.

ToDo:

	Add authentication.
	Add secure messaging.
	Reduce repeat code by moving 'Array.prototype.remove' somewhere more accessible.
	Better ID tracking for guest user assignment.

License:

	The MIT License (MIT)

	Copyright (c) 2013-2015, Nathan Bass

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
