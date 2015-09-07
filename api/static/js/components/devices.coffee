React = require 'react'
Router = require 'react-router'

{Link, RouteHandler} = Router

{DashboardDispatcher} = require '../dispatcher'

DevicesView = React.createClass

    getInitialState: ->
        items: []

    componentDidMount: ->
        devices$ = DashboardDispatcher.findDevices()
        devices$.onValue (items) => @setState {items}

    render: ->
        <div className='devices-list'>
            {@state.items.map (d) ->
                <DeviceListItem item=d />
            }
        </div>

DeviceListItem = React.createClass

    render: ->
        <Link to="device" params={{device_id:@props.item._id}} className='block-button'>
            <div className='device item'>
                <div className='kind'>{@props.item.kind}</div>
                <div className='device_id'>{@props.item.device_id}</div>
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
        <div>
            <h2>{'Device ' + device_id}</h2>
            <ul className="tabs">
                <li><Link to="device_data" params={device_id: device_id}>Data</Link></li>
                <li><Link to="device_hooks" params={device_id: device_id}>Hooks</Link></li>
            </ul>
            <RouteHandler device_id=device_id />
        </div>

# Graph/visualization of device data
DeviceDataView = React.createClass

    render: ->
        <div className='device-data'>
            This is a graph of the device
        </div>

# Hoooks associated with the device
DeviceHooksView = React.createClass

    render: ->
        <div className='device-hooks'>
            This is a page to set up hooks for this device
        </div>

module.exports = {
    DevicesView
    DeviceView
    DeviceDataView
    DeviceHooksView
}