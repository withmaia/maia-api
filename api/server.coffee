polar = require 'polar'
config = require '../config'
somata = require 'somata'

somata_client = new somata.Client

DataService = somata_client.bindRemote 'maia-api:data'
EngineService = somata_client.bindRemote 'maia-api:engine'

app = polar config.api

# "Hello, Maia"
app.get '/', (req, res) ->
    res.end 'Maia API v0.0.1'

# Post a new device with user credentials for validation
app.post '/devices.json', (req, res) ->
    {device_id, kind, device_id, username, password} = req.body
    user = {username, password}
    device = {device_id, kind}
    EngineService 'validateNewDevice', user, device, (err, new_device) ->
        if err?
            res.json success: false, error: err
        else
            res.json success: true, new_device

# Post a measurement from a device
app.post '/measurements.json', (req, res) ->
    {device_id, kind, value, unit} = req.body
    new_measurement = {device_id, kind, value, unit}
    DataService 'createMeasurement', new_measurement, (err, new_measurement) ->
        res.json new_measurement

app.start()
