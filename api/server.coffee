polar = require 'polar'
config = require '../config'

app = polar config.api

app.get '/hello_world.json', (req, res) ->
    res.json 'hello world'

app.post '/devices.json', (req, res) ->

    {kind, serial, username, password} = req.body
    # TODO: validate user
    # TODO: create device
    res.json {kind, serial, username, password}

app.post '/measurements.json', (req, res) ->

    {device_id, kind, value, unit} = req.body

    res.json {device_id, kind, value, unit}


app.start()
