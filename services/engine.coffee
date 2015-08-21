_ = require 'underscore'
somata = require 'somata'

somata_client = new somata.Client
DataService = somata_client.bindRemote 'maia:data'

validateNewDevice = (user, new_device, cb) ->
    DataService 'getUser', user, (err, user) ->
        if user?
            DataService 'createDevice', new_device, cb
        else
            cb "User invalid"

data_service = new somata.Service 'maia:engine', {
    validateNewDevice
}

