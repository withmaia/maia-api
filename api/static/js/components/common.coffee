React = require 'react'
moment = require 'moment'

renderDateString = (date) ->
    moment(date).format('dddd MMM Do')

Icon = React.createClass
    render: ->
        icon_class = 'fa fa-' + @props.icon
        <i className=icon_class />

module.exports = {
    Icon
}