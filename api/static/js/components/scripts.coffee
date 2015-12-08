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

empty_script =
    name: ''
    trigger: ''
    source: ''

NewScript = React.createClass
    getInitialState: ->
        script: @props.script || empty_script
        edited: !@props.script?
        errors: {}

    validate: ->
        {name, trigger, source} = @state.script
        errors = {}
        if !(name?.length)
            errors.name = "Name your script"
        if !(trigger?.length)
            errors.trigger = "Trigger your script"
        if !(source?.length)
            errors.source = "Source your script"
        @setState {errors}
        return Object.keys(errors).length == 0

    onChange: (key) -> (e) =>
        value = e.target.value
        state = @state
        state.edited = true
        state.script[key] = value
        @setState state

    onSubmit: (e) ->
        e.preventDefault()
        if @validate()
            if @props.script?
                DashboardDispatcher.updateScript @props.script._id, @state.script
            else
                DashboardDispatcher.createScript @state.script
            @setState @getInitialState()

    errorClass: (key) ->
        class_set = error: @state.errors[key]
        class_set[key] = true
        classSet class_set

    render: ->
        <div>
            <form onSubmit=@onSubmit>
                {if !@props.script? then <h2>Create a new script</h2>}
                <input value=@state.script.name onChange=@onChange('name') placeholder='name' className=@errorClass('name') />
                <input value=@state.script.trigger onChange=@onChange('trigger') placeholder='trigger' className=@errorClass('trigger') />
                <textarea value=@state.script.source onChange=@onChange('source') className=@errorClass('source') />
                {if @state.edited then <button>Save</button>}
            </form>
        </div>

# TODO: use axis-like admin item and items views
ScriptListItem = React.createClass
    getInitialState: ->
        edited: false

    delete: ->
        DashboardDispatcher.deleteScript @props.item._id

    toggleDisabled: ->
        if @props.item.disabled
            DashboardDispatcher.updateScript @props.item._id, {disabled: false}
        else
            DashboardDispatcher.updateScript @props.item._id, {disabled: true}

    onChange: (key) -> (e) =>
        value = e.target.value
        state = {}
        state[key] = value
        @setState state

    render: ->
        <div className='script item'>
            <div className='actions'>
                <a onClick=@delete>Delete</a>
                <a onClick=@toggleDisabled>{if @props.item.disabled then "Enable" else "Disable"}</a>
            </div>
            <NewScript script=@props.item />
        </div>

module.exports = {
    ScriptsView
}

