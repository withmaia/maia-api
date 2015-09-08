React = require 'react'
Router = require 'react-router'

{Link, RouteHandler} = Router

{DashboardDispatcher} = require '../dispatcher'

ScriptsView = React.createClass

    getInitialState: ->
        items: []

    componentDidMount: ->
        # TODO: name and load from dispatcher

    render: ->
        <div className='script-list'>
            <h1>My Scripts</h1>
            <p className='help'>Here are the scripts you have set up with Maia. A script can be installed/imported or written yourself.</p>
            {@state.items.map (d) ->
                <scriptListItem item=d />
            }
        </div>

# TODO: use axis-like admin item and items views
ScriptListItem = React.createClass

    render: ->
        <div className='script item'>
            <div className='kind'>{@props.item.kind}</div>
            <div className='name'>{@props.item.name}</div>
        </div>

module.exports = {
    ScriptsView
}