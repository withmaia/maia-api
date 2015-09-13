React = require 'react'
Router = require 'react-router'

{Link, RouteHandler} = Router

{DashboardDispatcher} = require '../dispatcher'

TriggersView = React.createClass

    getInitialState: ->
        items: []

    componentDidMount: ->
        # TODO: name and load from dispatcher

    render: ->
        <div className='trigger-list'>
            <h1>My Triggers</h1>
            <p className='help'>Here are the triggers you have set up with Maia. A trigger runs a script under certain conditions.</p>
            {@state.items.map (d) ->
                <TriggerListItem item=d />
            }
        </div>

# TODO: use axis-like admin item and items views
TriggerListItem = React.createClass

    render: ->
        <div className='trigger item'>
            <div className='kind'>{@props.item.kind}</div>
            <div className='name'>{@props.item.name}</div>
        </div>

module.exports = {
    TriggersView
}