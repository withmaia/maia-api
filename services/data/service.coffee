somata = require 'somata'
generic = require './generic'
schema = require './schema'
orm = require './orm'

# ------------------------------------------------------------------------------

data_methods = generic(schema)

data_methods.loginUser = (username, password, cb) ->

    user_query =
        username: {$regex: '^' + username.trim().toLowerCase() + '$', $options: 'i'}
        password: password

    data_methods.getUser user_query, (err, user) ->
        if user?
            cb null, user

        else
            # Maybe they used their email
            user_query =
                email: {$regex: '^' + username.trim().toLowerCase() + '$', $options: 'i'}
                password: password

            data_methods.getUser user_query, (err, user) ->
                if user?
                    cb null, user

                else
                    cb "Incorrect username or password"

data_service = new somata.Service 'itsmyurls:data', data_methods
