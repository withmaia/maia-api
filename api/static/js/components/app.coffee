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
            # {if @showHeader()
            #     <div id="header">
            #         {if @hasBack() then backButton}
            #         <span className="title">{@state.title}</span>
            #     </div>
            # }
        <div>
            <div id="nav">
                <h1>Maia Dashboard</h1>
                <Link to='devices' > Devices </Link>
                <Link to='hooks' > Events </Link>
                <Link to='hooks' > Webhooks </Link>
            </div>
            <div id="content">
                <div className='container'>
                    <Router.RouteHandler ref='handler' />
                </div>
            </div>
        </div>

module.exports = {
    AppView
}
