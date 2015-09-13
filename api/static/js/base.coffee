React = require 'react'
Router = require 'react-router'
_ = require 'underscore'

{TitleThrough} = require './helpers'
{AppView} = require './components/app'
{LoginView} = require './components/login'
{DevicesView, DeviceView, DeviceDataView, DeviceTriggersView, DevicesListView, AddDeviceView} = require './components/devices'
{TriggersView} = require './components/triggers'
{ScriptsView} = require './components/scripts'
{TriggersView} = require './components/triggers'
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
        <Route name="devices" path="devices" handler={requireLogin DevicesView} >
            <DefaultRoute name="devices_list" handler={DevicesListView} />
            <Route name="add_device" path="add" handler={AddDeviceView} />
        </Route>
        <Route name="device" path="devices/:device_id" handler={requireLogin DeviceView} >
            <DefaultRoute name="device_data" handler={requireLogin DeviceDataView} />
            <Route name="device_triggers" path="triggers" handler={requireLogin DeviceTriggersView} />
        </Route>
        <Route name="triggers" path="triggers" handler={requireLogin TriggersView} />
        <Route name="scripts" path="scripts" handler={requireLogin ScriptsView} />
    </Route>

Router.run routes, (Handler) ->
    window.scroll(0, 0)
    React.render <Handler />, document.getElementById('app')

