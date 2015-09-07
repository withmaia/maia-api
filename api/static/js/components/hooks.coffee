React = require 'react'
Router = require 'react-router'

{Link, RouteHandler} = Router

{DashboardDispatcher} = require '../dispatcher'

HooksView = React.createClass

    getInitialState: ->
        items: []

    componentDidMount: ->
        # TODO: name and load from dispatcher

    render: ->
        <div className='events-list'>
            <h1>My Events</h1>
            <p className='help'>{"Here are the hooks/events/actions (TODO: name everything) you have set up with Maia. An event/action/hook can be (e.g.) an SMS alert, telling the cube to bink its status, or turn on the tea."}</p>
            {@state.items.map (d) ->
                <HookListItem item=d />
            }
        </div>

# TODO: use axis-like admin item and items views
HookListItem = React.createClass

    render: ->
        <div className='hook item'>
            <div className='kind'>{@props.item.kind}</div>
            <div className='name'>{@props.item.name}</div>
        </div>

module.exports = {
    HooksView
}