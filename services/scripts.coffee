somata = require 'somata'
coffee = require 'coffee-script'

client = new somata.Client

watchScript = ({trigger, id}) ->
    [service, method] = trigger.split('.')
    client.on service, method, runScript(id)

unwatchScript = ({id}) ->
    console.log 'TODO: Unsubscribe event handler'

runScript = (id) -> (data) ->
    client.call 'maia:data', 'getScript', {id}, (err, script) ->
        compiled = coffee.compile script.source, bare: true
        fn = eval compiled
        fn(data)

# Get existing scripts on startup
client.call 'maia:data', 'findScripts', {}, (err, all_scripts) ->
    all_scripts.map watchScript

# Listen for created and removed scripts
client.on 'maia:data', 'addScript', watchScript
client.on 'maia:data', 'removeScript', unwatchScript
