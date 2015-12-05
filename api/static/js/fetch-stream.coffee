Kefir = require 'kefir'

extend = (os...) ->
	_o = {}
	for o in os
		for k, v of o
			_o[k] = v
	_o

default_options = credentials: 'same-origin'

fetch$ = (method, url, options={}) ->
    options = extend default_options, options
    options.method = method
    if options.json?
        json = options.json
        delete options.json
        options.headers = 'Content-Type': 'application/json'
        options.body = JSON.stringify json
    fetch_ = fetch(url, options).then (res) -> res.json()
    Kefir.fromPromise fetch_

module.exports = fetch$
