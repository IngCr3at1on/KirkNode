#
# Process an action (parsed from a json object).
#
# The variable 'client' will always refer to the originating client.
# 'json' will be the json object containing the action to be processed.
#

# Parse a json file for an action
parse: (client, json) ->
    # Check a json file for an action and switch on it if it's present.
    if json.action and typeof json.action is 'string'
        switch json.action
            # check against each defined action.
            when 'authenticate' then authenticate client, json
            when 'join' then join client, json
            when 'leave' then leave client, json
            when 'msg' then message client, json
            # Invalid action, return bad request.
            else client.write "{response: 400}"
    # Otherwise there is no action, return bad json.
    else client.write "{response: 400}"

# Authenticate a user on the server.
authenticate: (client, json) ->
    client.write "{response: 100, alert: 'Authentication is not enabled at this time.'}"

# Log a user into a channel.
join: (client, json) ->
    client.write "{response: 100, alert: 'Multi-user messaging is not enabled at this time.'}"

# Log a user out of a channel.
leave: (client, json) ->
    client.write "{response: 100, alert: 'Multi-user messaging is not enabled at this time.'}"

# Message a user or group (that the user/client is logged into)
message: (client, json) ->
    client.write "{response: 100, alert: 'Personal messaging is not enabled at this time.'}"
