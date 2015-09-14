React = require 'react'
Router = require 'react-router'

{Link, RouteHandler} = Router

{DashboardDispatcher} = require '../dispatcher'

ProjectsView = React.createClass

    getInitialState: ->
        items: []

    componentDidMount: ->
        # TODO: name and load from dispatcher

    render: ->
        <div className='trigger-list'>
            <h1>My Projects</h1>
            <p className='help'>Here are the projects people have shared. Select a project to see a tutorial and parts list then build it and add it to Maia!</p>
            {@state.items.map (d) ->
                <ProjectListItem item=d />
            }
        </div>

# TODO: use axis-like admin item and items views
ProjectListItem = React.createClass

    render: ->
        <div className='project item'>
            <div className='kind'>{@props.item.kind}</div>
            <div className='name'>{@props.item.name}</div>
        </div>

module.exports = {
    ProjectsView
}