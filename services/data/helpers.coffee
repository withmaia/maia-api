_ = require 'underscore'

# Avoid wasting time on static resources
static_exts = ['css','js','jpg','png','gif','woff', 'svg']
is_static_url = (url) -> url.split('.').slice(-1)[0] in static_exts

# Capitalize the first letter of a string
capitalize = (type) -> type[0].toUpperCase() + type.slice(1)

summarize = (o) ->
    so = util.inspect(o).replace(/\s+/g, ' ')
    if so.length > 50
        return so.slice(0, 50) + '...'
    else
        return so

# Generate a random alphanumeric string
randomString = (len=8) ->
    s = ''
    while s.length < len
        s += Math.random().toString(36).slice(2, len-s.length+2)
    return s

# Choose a random item from an array
randomChoice = (l) ->
    l[Math.floor(Math.random() * l.length)]

minsAgo = (num_mins) ->
    now  = new Date()
    mins_ago = now.getTime() - (num_mins * 60 * 1000)
    return mins_ago

hrs_ago_id_from_hours = (hrs_ago) ->
    now  = new Date()
    time_ago = new Date(now.getTime() - (hrs_ago * 60 * 60 * 1000))
    hex_seconds = Math.floor(time_ago/1000).toString(16)
    hrs_ago_id = orm.oid(hex_seconds + '0000000000000000')
    return hrs_ago_id

module.exports = {
    static_exts
    is_static_url
    capitalize
    summarize
    randomString
    randomChoice
    minsAgo
    hrs_ago_id_from_hours
}
