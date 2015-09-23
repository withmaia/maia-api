Kefir = require 'kefir'

# Helpers
# ------------------------------------------------------------------------------

fetch$ = (url, options={}) ->
    options.credentials = 'same-origin'
    fetch_ = fetch(url, options).then (res) -> res.json()
    Kefir.fromPromise fetch_

# Dispatcher
# ------------------------------------------------------------------------------

DashboardDispatcher =
    findDevices: ->
        fetch$ '/devices.json'

    findProjects: ->
        fetch$ '/projects.json'

    findDeviceMeasurements: (device_id) ->
        fetch$("/devices/#{device_id}/measurements.json")

    generateDeviceToken: ->
        fetch$("/device_token.json")

module.exports = {
    DashboardDispatcher
}

