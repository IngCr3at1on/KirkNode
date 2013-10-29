KirkNode is a node.js server to implement and test the [JIM protocol](https://jim.hackpad.com)

Written in coffeescript, the original joke was to name it "node.JIM"; being
boring that was replaced with KirkNode

Requirements:

	npm
	coffee-script (should be installed via npm)
	redis, needs to be installed and running

To start redis after installing (for testing) run the following before starting
KirkNode:

	redis-server &

Hit enter a second time and you should be able to start KirkNode properly. 
For information on starting Redis automatically see [Redis QuickStart](http://redis.io/topics/quickstart)

To get started with KirkNode run the following after cloning:

	npm install
	npm start

Install only needs to be ran the first time and only if coffee-script is not
installed on the system.
