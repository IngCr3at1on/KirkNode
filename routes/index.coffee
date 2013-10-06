exports.index = (req, res) ->
    res.render 'index',
        title: 'JIM test server'

exports.login = (req, res) ->
    res.render 'login',
        title: 'Please login'
