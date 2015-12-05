bus = require 'kefir-bus'
_ = require 'underscore'

StreamStore = {}

# A stream that calls a given stream-producing function to get new values and
# offers a .reload() method to call it again. 

ReloadableStream = (sf) ->
    _s$ = bus()
    s$ = _s$.toProperty()
    s$.raw$ = _s$
    s$.onValue (s) -> StreamStore[s$] = s
    s$.reload$ = bus()
    s$.loading$ = s$.reload$.awaiting s$
    s$.reload$.onValue -> _s$.plug sf() if sf?
    s$.reload = -> s$.reload$.emit true
    s$.update = (where, update) ->
        item = _.findWhere StreamStore[s$], where
        console.log '[ReloadableStream] item =', item
        if typeof update == 'function'
            update(item)
        else
            _.extend item, update
        _s$.emit StreamStore[s$]
    # process.nextTick ->
    #     s$.reload()
    return s$

module.exports = {ReloadableStream}
