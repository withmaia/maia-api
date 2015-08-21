somata = require 'somata'
generic = require './generic'
schema = require './schema'
orm = require './orm'

data_methods = generic(schema)

data_methods.loginUser = (email, password, cb) ->
    user_query =
        email: {$regex: '^' + email.trim().toLowerCase() + '$', $options: 'i'}
        password: password

    data_methods.getUser user_query, (err, user) ->
        if user?
            cb null, user

        else
            cb "Incorrect email or password"

data_service = new somata.Service 'maia:data', data_methods
