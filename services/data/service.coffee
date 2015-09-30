somata = require 'somata'
generic = require './generic'
schema = require './schema'
orm = require './orm'

data_methods = generic(schema)

hrs_ago_id_from_hours = (hrs_ago) ->
    now  = new Date()
    time_ago = new Date(now.getTime() - (hrs_ago * 60 * 60 * 1000))
    hex_seconds = Math.floor(time_ago/1000).toString(16)
    hrs_ago_id = orm.oid(hex_seconds + '0000000000000000')
    return hrs_ago_id

data_methods.loginUser = (email, password, cb) ->
    user_query =
        email: {$regex: '^' + email.trim().toLowerCase() + '$', $options: 'i'}
        password: password

    data_methods.getUser user_query, (err, user) ->
        if user?
            cb null, user

        else
            cb "Incorrect email or password"

data_methods.findDeviceMeasurements = (device_id, cb) ->

    device_query =
        _id: {$gt: hrs_ago_id_from_hours(48)}
        device_id: device_id

    schema.Measurements.findArray device_query, (err, measurements) ->

        measurements.map (m) ->
            m.created_at = m.createdAt()

        cb err, measurements

data_service = new somata.Service 'maia:data', data_methods
