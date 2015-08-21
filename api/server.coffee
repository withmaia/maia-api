polar = require 'polar'
config = require '../config'
somata = require 'somata'
announce = require 'nexus-announce'

somata_client = new somata.Client

DataService = somata_client.bindRemote 'maia:data'
EngineService = somata_client.bindRemote 'maia:engine'

app = polar config.api

# "Hello, Maia"
app.get '/', (req, res) ->
    res.end 'Maia API v0.0.1'

# Post a new device with user credentials for validation
app.post '/devices.json', (req, res) ->
    {device_id, kind, email, password} = req.body
    device = {device_id, kind}
    user = {email, password}
    EngineService 'validateNewDevice', user, device, (err, new_device) ->
        if err?
            res.json success: false, error: err
        else
            announce 'maia:create-device', {device: new_device} if !config.LOCAL
            res.json success: true, new_device

# Post a measurement from a device
app.post '/measurements.json', (req, res) ->
    {device_id, kind, value, unit} = req.body
    measurement = {device_id, kind, value, unit}
    DataService 'createMeasurement', measurement, (err, new_measurement) ->
        announce 'maia:create-measurement', {measurement: new_measurement} if !config.LOCAL
        res.json new_measurement

app.start()

