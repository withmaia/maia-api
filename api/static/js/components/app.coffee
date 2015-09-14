React = require 'react'
Router = require 'react-router'

{Link} = Router

{Icon} = require './common'

# Base views
# ------------------------------------------------------------------------------

AppView = React.createClass
    mixins: [Router.State, Router.Navigation]

    getInitialState: ->
        title: 'Maia Dashboard'

    goHome: ->
        @transitionTo '/'

    hasBack: ->
        @getPath() != '/' and Router.History.length > 1

    componentDidMount: ->
        @setTitle()

    componentDidUpdate: ->
        @setTitle()

    setTitle: ->
        handler = @refs.handler.refs.__routeHandler__
        window.h = @refs.handler
        title = if handler?.title? then handler.title() else 'Maia Dashboard'
        if title != @state.title
            @setState {title}

    showHeader: ->
        route = @getRoutes().slice(-1)[0]
        return route.path not in ['/login']

    render: ->
        route = @getRoutes().slice(-1)[0]
        handler = route.handler
        backButton = <a onClick=@goBack className="back"><Icon icon='chevron-left' /></a>

        # tabs
        active_tab = @getPath().split('/')[1] || ''
        if active_tab == 'devices'
            devices_active = 'active'
        else if active_tab == 'scripts'
            scripts_active = 'active'
        else if active_tab == 'projects'
            projects_active = 'active'

        <div>
            <ul className="nav">
                <img className='logo' src='/images/logo-lg.png' />
                <li className={devices_active} ><Link to="devices" >Devices</Link></li>
                <li className={scripts_active} ><Link to="scripts" >Scripts</Link></li>
                <li className={projects_active} ><Link to="projects" >Projects</Link></li>
            </ul>
            <div id="content">
                <div className='container'>
                    <Router.RouteHandler ref='handler' />
                </div>
            </div>
        </div>

module.exports = {
    AppView
}
