_ = require 'underscore'
React = require 'react'
ReactDOM = require 'react-dom'
{IndexRoute, Route, Router} = require 'react-router'
createHistory = require 'history/lib/createHashHistory'

{TitleThrough} = require './helpers'
{AppView} = require './components/app'
{LoginView} = require './components/login'
{SignupView} = require './components/signup'
{DevicesView, DeviceView, DeviceDataView, DeviceTriggersView, DevicesListView, AddDeviceView} = require './components/devices'
{ScriptsView} = require './components/scripts'
{ProjectsView} = require './components/projects'

# Permissions
# ------------------------------------------------------------------------------

requireLogin = (nextState, replaceState) ->
    console.log 'requireing login'
    next_path = nextState.location.pathname

    if (not user? && next_path!='/login' && next_path!='/signup')
        replaceState nextPathname: next_path, '/login'

    else if next_path == '/'
        replaceState nextPathname: next_path, '/devices'
    

# Routes
# ------------------------------------------------------------------------------

routes =
    <Route name="app" path="/" component={AppView} onEnter=requireLogin >
        <Route name="login" path="login" component={LoginView} />
        <Route name="signup" path="signup" component={SignupView} />

        <Route name="devices" path="devices" component=DevicesView onEnter=requireLogin >
            <IndexRoute name="devices_list" component={DevicesListView} />
            <Route name="add_device" path="add" component={AddDeviceView} />
        </Route>

        <Route name="device" path="devices/:device_id" component=DeviceView onEnter=requireLogin >
            <IndexRoute name="device_data" component=DeviceDataView onEnter=requireLogin />
            <Route name="device_triggers" path="triggers" component=DeviceTriggersView onEnter=requireLogin />
        </Route>

        <Route name="scripts" path="scripts" component=ScriptsView onEnter=requireLogin />
        <Route name="projects" path="projects" component=ProjectsView onEnter=requireLogin />

    </Route>

history = createHistory(queryKey: false)

ReactDOM.render(<Router routes={routes} history={history} />, document.getElementById('app'))
