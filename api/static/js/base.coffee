React = require 'react'
Router = require 'react-router'
_ = require 'underscore'

{TitleThrough} = require './helpers'
{AppView} = require './components/app'
{LoginView} = require './components/login'
{DevicesView, DeviceView, DeviceDataView, DeviceHooksView} = require './components/devices'
{Route, DefaultRoute} = Router

# Routes
# ------------------------------------------------------------------------------

requireLogin = (Handler) ->
    React.createClass
        mixins: [TitleThrough()]
        statics: willTransitionTo: (transition) ->
            console.log 'willTransitionTo', transition.path
            if not user?
                transition.redirect '/login'
        render: ->
            <Handler ref='page' />

routes =
    <Route name="app" path="/" handler={AppView}>
        <Route name="login" path="login" handler={LoginView} />
        <Route name="devices" path="devices" handler={requireLogin DevicesView} />
        <Route name="device" path="devices/:device_id" handler={requireLogin DeviceView} >
            <DefaultRoute name="device_data" handler={requireLogin DeviceDataView} />
            <Route name="device_hooks" path="hooks" handler={requireLogin DeviceHooksView} />
        </Route>
    </Route>

Router.run routes, (Handler) ->
    window.scroll(0, 0)
    React.render <Handler />, document.getElementById('app')

