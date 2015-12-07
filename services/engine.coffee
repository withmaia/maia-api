somata = require 'somata'
redis = require('redis').createClient null, null
auth = require '../api/auth'

somata_client = new somata.Client
DataService = somata_client.bindRemote 'maia:data'

# Device registration
# ------------------------------------------------------------------------------

validateNewDevice = (new_device, token, cb) ->

    redis.hgetall token, (err, obj) ->
        if !obj?.user_id?
            cb 'Invalid Token'
        else
            DataService 'getUser', {_id: obj.user_id}, (err, user) ->
                if user?
                    new_device.user_id = user._id
                    DataService 'createDevice', new_device, cb
                else
                    cb "User invalid"

generateDeviceToken = (user, cb) ->
    token = auth.randomString 6

    verification =
        user_id: user._id
        token: token

    redis.hmset token, verification
    redis.expire token, 10*60 # Good for 10 min

    cb null, token


data_service = new somata.Service 'maia:engine', {
    validateNewDevice
    generateDeviceToken
}

