_ = require 'underscore'
somata = require 'somata'

somata_client = new somata.Client

DataService = somata_client.bindRemote 'maia-api:data'

validateNewDevice = (user, new_device, cb) ->

    user_query =
        username: user.username
        password: user.password

    DataService.getUser user_query, (err, user) ->
        if user?
            DataService 'createDevice', new_device, (err, created) ->
                cb err, created

data_service = new somata.Service 'maia-api:engine', {
    validateNewDevice
}
