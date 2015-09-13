Kefir = require 'kefir'
bus = require 'kefir-bus'

repeating = (t, v) ->
    Kefir.constant(v).concat(Kefir.interval(t, v))
        .toProperty()

ReloadableStream = (sf) ->
    s$ = bus()
    s$p = s$.toProperty()
    s$p.plug = s$.plug.bind(s$)
    s$p.emit = s$.emit.bind(s$)
    s$p.reload$ = bus()
    s$p.loading$ = s$p.reload$.awaiting s$
    s$p.reload$.onValue -> s$.plug sf()
    s$p.reload = -> s$p.reload$.emit true
    process.nextTick ->
        s$p.reload()
    return s$p

module.exports = {
    repeating
    ReloadableStream
}