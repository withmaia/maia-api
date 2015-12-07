React = require 'react'
Router = require 'react-router'
classSet = require 'react-classset'
{DashboardDispatcher} = require '../dispatcher'

{Link, RouteHandler} = Router

ScriptsView = React.createClass
    getInitialState: ->
        items: []

    componentDidMount: ->
        DashboardDispatcher.scripts$.onValue (items) => @setState {items}

    render: ->
        <div className='script-list'>
            <h1>My Scripts</h1>
            <p className='help'>Here are the scripts you have set up with Maia. A script can be installed/imported or written yourself.</p>
            {
                if @state.items.length
                    @state.items.map (d) -> <ScriptListItem key=d._id item=d />
                else
                    <p>No scripts.</p>
            }
            <NewScript />
        </div>

NewScript = React.createClass
    getInitialState: ->
        name: ''
        trigger: ''
        source: ''
        errors: {}

    validate: ->
        return true

    onChange: (key) -> (e) =>
        value = e.target.value
        state = {}
        state[key] = value
        @setState state

    onSubmit: (e) ->
        e.preventDefault()
        if @validate()
            DashboardDispatcher.createScript
                name: @state.name
                trigger: @state.trigger
                source: @state.source
            @setState @getInitialState()

    errorClass: (key) ->
        classSet error: @state.errors[key]

    render: ->
        <div>
            <form onSubmit=@onSubmit>
                <h2>Create a new script</h2>
                <input value=@state.name onChange=@onChange('name') placeholder='name' className=@errorClass('name') />
                <input value=@state.trigger onChange=@onChange('trigger') placeholder='trigger' className=@errorClass('trigger') />
                <textarea value=@state.source onChange=@onChange('source') className=@errorClass('source') placeholder='source' />
                <button className='touch-button'>Create</button>
            </form>
        </div>

# TODO: use axis-like admin item and items views
ScriptListItem = React.createClass
    delete: ->
        DashboardDispatcher.deleteScript @props.item._id

    render: ->
        <div className='script item'>
            <div className='actions'>
                <a onClick=@delete>Delete</a>
            </div>
            <span className='name'>{@props.item.name}</span>
            <span className='trigger'>{@props.item.trigger}</span>
            <pre className='source'>{@props.item.source}</pre>
        </div>

module.exports = {
    ScriptsView
}

