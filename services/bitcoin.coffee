somata = require 'somata'
request = require 'request'

randomChoice = (l) -> l[Math.floor(Math.random()*l.length)]

last_prices = [0]
last_color = 'g'
u = 'https://api.bitcoinaverage.com/ticker/global/USD/'

THRESHOLD = 5

notzero = (n) -> n != 0
add = (a, b) -> a + b

wadd = (a, b, i) -> a + b * (i + 1)
wlen = (l) -> l.map(-> 1).reduce(wadd)
wavg = (l) -> l.reduce(wadd)/wlen(l)

higher =
    g: 'a'
    r: 'p'

colorForPrice = (price) ->
    last_price = last_prices.slice(-1)[0]
    if last_price == 0 # No price yet
        c = 'y'
    else
        recent_prices = last_prices.filter(notzero).slice(-5)
        recent_avg = wavg recent_prices
        console.log "#{last_price} -> #{price}"
        console.log 'recent: ', recent_avg
        if price > recent_avg
            c = 'g'
        else
            c = 'r'
        diff = Math.abs(price - recent_avg)
        console.log 'diff', diff
        if diff > 1
            c = higher[c]
        if diff < 0.25
            c = 'y'
    last_prices.push price
    last_color = c
    return [price, c]

showPriceColors = (price_colors) ->
    for [price, color] in price_colors
        console.log '    ' + price + ' ' + color

DEBUG = false
if DEBUG
    console.log 'Prices:'
    showPriceColors [242, 240, 239, 200, 201, 202, 209, 210, 190].map colorForPrice
    process.exit()

getPriceColor = (cb) ->
    request.get u, {json: true}, (err, got, data) ->
        [price, c] = colorForPrice data.last
        console.log "COLOR: #{c}"
        cb null, c

service = new somata.Service 'maia:bitcoin', {getPriceColor}

