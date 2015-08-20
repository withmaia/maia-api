polar = require 'polar'
config = require './config'

app = polar config.api

app.get '/hello_world.json', (req, res) ->
    res.json 'hello world'

app.start()
