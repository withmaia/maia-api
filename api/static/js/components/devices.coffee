React = require 'react'
Router = require 'react-router'

{Link, RouteHandler} = Router

{Graph} = require './graph'

{DashboardDispatcher} = require '../dispatcher'

DevicesView = React.createClass
    mixins: [Router.State]

    render: ->
        <div className='devices-list'>
            <RouteHandler />
        </div>

DevicesListView = React.createClass

    getInitialState: ->
        items: []

    componentDidMount: ->
        devices$ = DashboardDispatcher.findDevices()
        devices$.onValue (items) => @setState {items}

    render: ->
        <div className='devices-list'>
            <Link className='add-link' to='add_device'>Connect a new device</Link>
            <h1>My Devices</h1>
            <p className='help'>Here are the devices you have connected with Maia. Select a device to view it's data or set up triggers.</p>
            {@state.items.map (d) ->
                <DeviceListItem item=d />
            }
        </div>

DeviceListItem = React.createClass

    componentDidMount: ->
        measurements$ = DashboardDispatcher.findDeviceMeasurements @props.item._id
        measurements$.onValue (measurements) => @loadedMeasurements measurements

    loadedMeasurements: (d_ms) ->
        d_ms.map (d_m) ->
            d_m.t = new Date d_m.created_at

        graph = @refs.graph
        graph.setupGraph()
        graph.setupAxes d_ms, d_ms
        console.log @props.item
        d = @props.item
        graph.renderLine options: d, values: d_ms

    render: ->
        d = @props.item

        <Link to="device" params={{device_id: d._id}} className='block-button'>
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
    mixins: [Router.State]

    getInitialState: ->
        loading: false

    render: ->
        device_id = @getParams().device_id

        if @state.loading
            return <em>Loading..</em>

        # tabs
        active_tab = @getPath().split('/').slice(-1)[0]
        if active_tab == 'triggers'
            triggers_active = 'active'
        else
            data_active = 'active'

        <div>
            <h1><Link className='back' to="devices"><i className='fa fa-chevron-left' /></Link>{'Device ' + device_id}</h1>
            <ul className="tabs">
                <li className={data_active}><Link to="device_data" params={device_id: device_id}>Data</Link></li>
                <li className={triggers_active}><Link to="device_triggers" params={device_id: device_id}>Triggers</Link></li>
            </ul>
            <p className='help'>Here are some details about the device</p>
            <RouteHandler device_id=device_id />
        </div>

# Device details
AddDeviceView = React.createClass
    mixins: [Router.State]

    render: ->

        <div className='add-device'>
            <h1>Connect a Device</h1>
            <p className='help'>Add a new device!</p>
            <div className='how-to'>Plug a battery into your device and connect to the wifi network called: "Maia Setup 0x..."</div>
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