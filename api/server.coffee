polar = require 'polar'
config = require '../config'
somata = require 'somata'
announce = require 'nexus-announce'

auth = require './auth'
users = require './users'

somata_client = new somata.Client

DataService = somata_client.bindRemote 'maia:data'
EngineService = somata_client.bindRemote 'maia:engine'
BitcoinService = somata_client.bindRemote 'maia:bitcoin'

user_middleware = (req, res, next) ->
    # If the request has a session user, find the relevant user
    if user_id = req.session.user_id
        DataService 'getUser', {_id: user_id}, (err, user) =>
            res.locals.user = user
            next()
    else
        next()

app = polar config.api, middleware: [user_middleware, users], debug: true

# "Hello, Maia"
app.get '/', (req, res) ->
    res.end 'Maia API v0.0.1'

app.get '/dashboard', (req, res) ->
    res.render 'dashboard'

# Devices
# ------------------------------------------------------------------------------

# Post a new device with user credentials for validation
app.post '/devices.json', (req, res) ->
    {device_id, kind, token} = req.body
    device = {device_id, kind}

    EngineService 'validateNewDevice', device, token, (err, new_device) ->
        if err?
            res.send 401, error: err
        else
            announce 'maia:create-device', {device: new_device} if !config.LOCAL
            res.json success: true, new_device

# Get devices for a user
app.get '/devices.json', (req, res) ->
    DataService 'findDevices', {}, (err, devices) ->
        res.json devices

app.get '/device_token.json', (req, res) ->
    EngineService 'generateDeviceToken', res.locals.user, (err, token) ->
        res.json token

# Measurements
# ------------------------------------------------------------------------------
# Post a measurement from a device
app.post '/measurements.json', (req, res) ->
    {device_id, kind, value, unit} = req.body
    measurement = {device_id, kind, value, unit}
    DataService 'createMeasurement', measurement, (err, new_measurement) ->
        console.log 'error: ', err if err?
        announce 'maia:create-measurement', {measurement: new_measurement} if !config.LOCAL
        res.json new_measurement

app.get '/devices/:device_id/measurements.json', (req, res) ->
    {device_id} = req.params
    DataService 'findDeviceMeasurements', device_id, (err, measurements) ->
        res.json measurements

app.get '/cube.color', (req, res) ->
    BitcoinService 'getPriceColor', (err, color) ->
        res.end color

# Scripts
# ------------------------------------------------------------------------------

app.get '/scripts.json', (req, res) ->
    DataService 'findScripts', {}, (err, scripts) ->
        res.json scripts

# Projects
# ------------------------------------------------------------------------------

mock_projects = [
    kind: 'device'
    name: 'attinytemp'
    description: 'wifi enabled temperature sensor'
    image: '/images/attinytemp1.jpg'
,
    kind: 'script'
    name: 'sunrise simulator'
    description: 'wake up to a sunrise, no sun required'
    image: '/images/sunrise.jpg'
,
    kind: 'device'
    name: 'light cube'
    description: 'internet connected ambient display'
    image: '/images/lightcube.jpg'
,
    kind: 'device'
    name: 'attinytoggle'
    description: 'window and door opening sensor'
    image: '/images/door.jpg'
]

app.get '/projects.json', (req, res) ->
    res.json mock_projects
    # DataService 'findProjects', {}, (err, projects) ->
        # res.json projects
        # project =
        #     kind: 'device/script'
        #     name: ''
        #     description: ''
        #     image: ''
        #     tutorial_id:

app.get '/devices/:device_id/scripts/:script_slug.json', (req, res) ->
    # run script w/ {device_id, script_slug}
    
# Subscription route for teaser site
app.post '/subscribe.json', (req, res) ->
    {email} = req.body
    ip = req.connection.remoteAddress
    new_subscription = {email, ip, kind: 'mailing-list'}
    announce 'maia:create-subscription', new_subscription if !config.LOCAL
    DataService 'createSubscription', new_subscription, ->
    res.setHeader 'Access-Control-Allow-Origin', '*'
    res.json success: true

app.start()

