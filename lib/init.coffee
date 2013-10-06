express = require 'express'

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy

io = require 'socket.io'
net = require 'net'

app = express()

app.configure ->
    app.set 'port', process.env.PORT or 8124
    app.use express.logger('dev')
    app.use express.cookieParser('keep it secret')
    app.use express.bodyParser()
    app.use express.session()
    app.use passport.initialize()
    app.use passport.session()
    app.use require('connect-assets')()
    app.use server.router

app.configure 'development', ->
    app.use express.errorHandler()

ensureAuthentication = (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.redirect '/login'

login = (username, password, done) ->
    if username == 'ace' && password == 'testing'
        done null, { id: 1, user: 'ace' }
    else
        done null, { message: 'Invalid username or password.' }

passport.serializeUser (user, done) ->
    done null, user.id

passport.deserializeUser (id, done) ->
    done null, id

passport.use new LocalStrategy(login)

#app.get '/', ensureAuthentication, routes.index
#app.get '/login' ->
    # I believe this should send the login request but I'm a bit lost as the
    # client should handle sending that. So, failure lol

app.get '/logout', (req, res) ->
    req.logout()

# course this would make more sense as far as sending login requests go...
app.post '/login', passport.authenticate('local', { successRedirect: '/failedRedirect', failureRedirect: '/login' })

server = net.createServer app
server.listen app.get('port'), ->
    console.log 'JIM test server, listening on ' + app.get('port')

socket = io.listen server

socket.on 'connection', (client)->
    console.log 'client connected'
    client.write "{response: 200}"

    client.on 'end', ->
	    console.log 'client disconnected'


    client.on 'data', (json) ->
        client.write json
        console.log json.toString()
