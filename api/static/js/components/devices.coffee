React = require 'react'
{Router, Link, RouteHandler} = require 'react-router'

{Graph} = require './graph'

{DashboardDispatcher} = require '../dispatcher'

DevicesView = React.createClass

    render: ->

        <div className='devices-list'>
            {@props.children}
        </div>

DevicesListView = React.createClass

    getInitialState: ->
        items: []

    componentDidMount: ->
        devices$ = DashboardDispatcher.findDevices()
        devices$.onValue (items) => @setState {items}

    render: ->

        <div className='devices-list'>
            <Link className='add-link' to='/devices/add'>Connect a new device</Link>
            <h1>My Devices</h1>
            {@state.items.map (d) ->
                <DeviceListItem item=d />
            }
        </div>

DeviceListItem = React.createClass

    componentDidMount: ->
        measurements$ = DashboardDispatcher.findDeviceMeasurements @props.item.device_id
        measurements$.onValue (measurements) => @loadedMeasurements measurements

    loadedMeasurements: (d_ms) ->

        d_ms = d_ms.filter (d_m) ->
            # Only show temperatures and filter out squirrely values for now
            return (d_m.kind == 'temperature') && (d_m.value.indexOf(' ') < 0)

        d_ms.map (d_m) ->
            d_m.t = new Date d_m.created_at

        graph = @refs.graph
        graph.setupGraph()
        graph.setupAxes d_ms, d_ms
        graph.drawAxes()
        d = @props.item
        graph.renderLine options: d, values: d_ms

    render: ->
        d = @props.item

        <Link to="/devices/#{d._id}" className='block-button'>
            <div className='device item'>
                <i className='fa fa-circle' />
                <div className='kind'>{d.kind}</div>
                <i className='fa fa-gear' />
                <div className='device_id'>{d.device_id}</div>
                <Graph ref={'graph'} />
            </div>
        </Link>

# Device details
DeviceView = React.createClass
    contextTypes:
        location: React.PropTypes.object

    getInitialState: ->
        loading: false

    render: ->
        device_id = @props.params.device_id

        if @state.loading
            return <em>Loading..</em>

        # tabs
        active_tab = @context.location.pathname.split('/').slice(-1)[0]

        if active_tab == 'triggers'
            triggers_active = 'active'
        else
            data_active = 'active'

        <div>
            <h1><Link className='back' to="devices"><i className='fa fa-chevron-left' /></Link>{'Device ' + device_id}</h1>
            <ul className="tabs">
                <li className={data_active}><Link to="/devices/#{device_id}" >Data</Link></li>
                <li className={triggers_active}><Link to="/devices/#{device_id}/triggers" >Triggers</Link></li>
            </ul>
            <p className='help'>Here are some details about the device</p>
            {@props.children}
        </div>

# Device details
AddDeviceView = React.createClass

    getInitialState: ->
        token: null

    componentDidMount: ->
        @token$ = DashboardDispatcher.generateDeviceToken()
        @token$.onValue (items) => @setToken items

    componentWillUnmount: ->
        @token$.offValue (items) => @setToken items

    setToken: (token) ->
        @setState {token}

    render: ->

        <div className='add-device'>
            <h1>Connect a Device</h1>
            <p className='help'>Registration token</p>
            <code className='token'>{@state.token}</code>
            <p className='help'>Instructions</p>
            <div className='how-to'>Keep this, youll need it soon</div>
            <div className='how-to'>Plug a battery into your device</div>
            <div className='how-to'> and connect to the wifi network called: "Maia Setup 0x..."</div>
            <div className='how-to'>Once connected, open the device registration page at <a href='http://10.10.10.1/register'>http://10.10.10.1/register</a> to contine</div>
        </div>

# Graph/visualization of device data
DeviceDataView = React.createClass

    render: ->
        <div className='device-data card'>
            This is a graph of the device
        </div>

# Triggers associated with the device
DeviceTriggersView = React.createClass

    render: ->
        <div className='device-triggers card'>
            This is a page to set up triggers for this device
        </div>

module.exports = {
    DevicesView
    DevicesListView
    DeviceView
    AddDeviceView
    DeviceDataView
    DeviceTriggersView
}