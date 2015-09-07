moment = require 'moment'

extend = (o1, o2) ->
    for k, v of o2
        o1[k] = v
    return o1

setPath = (obj, path, value) ->
    parts = path.split('.')
    if parts.length == 1
        obj[path] = value
    else
        obj_ = obj[parts[0]]
        if !obj_ then obj_ = obj[parts[0]] = {}
        setPath(obj_, parts.slice(1).join('.'), value)

flattenObject = (obj, prefix='') ->
    flattened = {}
    for k, v of obj
        if typeof v == 'object'
            extend flattened, flattenObject(v, prefix + k + '.')
        else
            flattened[prefix + k] = v
    return flattened

unslugify = (s) -> s.toLowerCase().replace(/_/g, ' ')
slugify = (s) -> s.toLowerCase().replace(/\S+/g, '_')

isEven = (n) -> n % 2 == 0
isOdd = (n) -> n % 2 == 1

TitleThrough = (fallback='Maia Dashboard') ->
    title: ->
        @refs.page.title?() || fallback

module.exports = {
    setPath
    flattenObject
    unslugify
    slugify
    isEven
    isOdd
    TitleThrough
}
