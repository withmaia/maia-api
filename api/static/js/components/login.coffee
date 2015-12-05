React = require 'react'
{Router, Link, History} = require 'react-router'

{ValidatedForm} = require 'react-zamba/lib/forms'

login_fields = [
    {name: 'email', type: 'email'}
    {name: 'password', type: 'password'}
]

LoginView = React.createClass
    mixins: [ History ]

    didLogin: ({success, user}) ->
        window.user = user
        @history.pushState null, '/devices'

    render: ->
        <div>
            <div className='center'>
                <div className='logo'><img src='/images/logo.png' /></div>
            </div>

            <div className='login-view'>
                <div className='instructions'>Log into your Maia account</div>
                <ValidatedForm action='/login.json' fields=login_fields focus=true onSuccess=@didLogin button={className:'touch-button', text: 'Log in', loading_text: 'Logging in...'} />
                <Link to='/signup'>Don't have an account?</Link>
            </div>
        </div>

module.exports = {LoginView}
