React = require 'react'
{Router, Link, History} = require 'react-router'

{ValidatedForm} = require 'react-zamba/lib/forms'

signup_fields = [
    {name: 'email', type: 'email'}
    {name: 'password', type: 'password'}
]

SignupView = React.createClass
    mixins: [ History ]

    didSignup: ({success, user}) ->
        window.user = user
        @history.pushState null, '/devices'

    render: ->
        <div>
            <div className='center'>
                <div className='logo'><img src='/images/logo.png' /></div>
            </div>

            <div className='signup-view'>
                <div className='instructions'>Create a new Maia account</div>
                <ValidatedForm action='/signup.json' fields=signup_fields focus=true onSuccess=@didSignup button={className:'touch-button', text: 'Register', loading_text: 'Registering...'} />
                <Link to='/login'>Already have an account?</Link>
            </div>
        </div>

module.exports = {SignupView}
