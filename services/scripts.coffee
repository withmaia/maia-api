somata = require 'somata'
coffee = require 'coffee-script'
util = require 'util'

client = new somata.Client

runScript = (trigger, source) ->
    compiled = coffee.compile source, bare: true
    console.log 'compiled: ', compiled
    fn = eval compiled
    [service, method] = trigger.split('.')
    console.log [service, method]
    client.on service, method, fn

trigger = 'maia:hue.changeState'
source = '''
({id, state}) ->
    console.log "Light #" + id + " turned " + (if state.on then "on" else "off")
    if id == 1
        client.remote 'maia:hue', 'setState', 4, state
'''

runScript trigger, source

