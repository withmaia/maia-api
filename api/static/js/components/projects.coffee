React = require 'react'
Router = require 'react-router'

{Link, RouteHandler} = Router

{DashboardDispatcher} = require '../dispatcher'

ProjectsView = React.createClass

    getInitialState: ->
        items: []

    componentDidMount: ->
        projects$ = DashboardDispatcher.findProjects()
        projects$.onValue (items) => @setState {items}

    render: ->
        <div className='projects-list'>
            <h1>Shared Projects</h1>
            <p className='help'>Select a project to see a tutorial and parts list. Order the parts, build it, then connect it to Maia!</p>
            {@state.items.map (d) ->
                <ProjectListItem item=d />
            }
        </div>

ProjectListItem = React.createClass

    render: ->
        <div className='project item'>
            <i className={'kind fa ' + (if @props.item.kind == 'device' then 'fa-cogs' else 'fa-file-code-o')} />
            <div className='name'>{@props.item.name}</div>
            <div className='description'>{' - ' + @props.item.description}</div>
            <div className='card'>
                <img className='main-image' src='/' />
            </div>
        </div>

module.exports = {
    ProjectsView
}