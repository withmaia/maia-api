Kefir = require 'kefir'
fetch$ = require './fetch-stream'
{ReloadableStream} = require './stream-helpers'

# Dispatcher
# ------------------------------------------------------------------------------

DashboardDispatcher =
    findDevices: ->
        fetch$ 'get', '/devices.json'

    findProjects: ->
        fetch$ 'get', '/projects.json'

    findDeviceMeasurements: (device_id) ->
        fetch$('get', "/devices/#{device_id}/measurements.json")

    generateDeviceToken: ->
        fetch$('get', "/device_token.json")

    findScripts: ->
        fetch$ 'get', '/scripts.json'

    createScript: (new_script) ->
        fetch$('post', '/scripts.json', json: new_script).onValue ->
            DashboardDispatcher.scripts$.reload()


    deleteScript: (script_id) ->
        fetch$('delete', "/scripts/#{script_id}.json").onValue ->
            DashboardDispatcher.scripts$.reload()

DashboardDispatcher.scripts$ = ReloadableStream DashboardDispatcher.findScripts
DashboardDispatcher.scripts$.reload()

module.exports = {
    DashboardDispatcher
}

