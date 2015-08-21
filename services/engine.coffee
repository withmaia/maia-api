_ = require 'underscore'
somata = require 'somata'
announce = require 'nexus-announce'
config = require '../config'

somata_client = new somata.Client
DataService = somata_client.bindRemote 'maia:data'

validateNewDevice = (user, new_device, cb) ->
    DataService 'getUser', user, (err, user) ->
        if user?
            new_device.user_id = user._id
            announce 'maia:register', {device: new_device} if !config.LOCAL
            DataService 'createDevice', new_device, cb
        else
            cb "User invalid"

data_service = new somata.Service 'maia:engine', {
    validateNewDevice
}

