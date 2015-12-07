somata = require 'somata'
coffee = require 'coffee-script'

client = new somata.Client

subscribed = {}

watchScript = ({trigger, _id}) ->
    [service, method] = trigger.split('.')
    subscription = client.on service, method, runScript(_id)
    subscribed[_id] = subscription

unwatchScript = ({_id}) ->
    client.unsubscribe subscribed[_id]

runScript = (_id) -> (data) ->
    client.call 'maia:data', 'getScript', {_id}, (err, script) ->
        if script.disabled then return
        compiled = coffee.compile script.source, bare: true
        fn = eval compiled
        fn(data)

# Get existing scripts on startup
client.call 'maia:data', 'findScripts', {}, (err, all_scripts) ->
    all_scripts.map watchScript

# Listen for created and removed scripts
client.on 'maia:data', 'createScript', watchScript
client.on 'maia:data', 'removeScript', unwatchScript
