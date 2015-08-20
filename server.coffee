polar = require 'polar'
config = require './config'

app = polar config.api

app.get '/hello_world.json', (req, res) ->
    res.json 'hello world'

app.post '/devices.json', (req, res) ->

    {kind, username, password} = req.body
    # TODO: validate user
    # TODO: create device
    res.json {kind, username, password}

app.start()
