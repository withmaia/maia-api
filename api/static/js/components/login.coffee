React = require 'react'
Router = require 'react-router'

{Link} = Router

{ValidatedForm} = require 'react-zamba/lib/forms'

login_fields = [
    {name: 'email', type: 'email'}
    {name: 'password', type: 'password'}
]

LoginView = React.createClass
    mixins: [Router.Navigation]

    didLogin: ({success, user}) ->
        window.user = user
        @transitionTo 'devices'

    render: ->
        <div>
            <div className='center'>
                <div className='logo'><img src='/images/logo.png' /></div>
                <h1>Maia</h1>
                <h2>Please log in</h2>
            </div>

            <div className='login-view'>
                <ValidatedForm action='/login.json' fields=login_fields focus=true onSuccess=@didLogin />
            </div>
        </div>

module.exports = {LoginView}
