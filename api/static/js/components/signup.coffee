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
        <div className='center-center'>
            <div className='signup-view'>
                <img className='logo' src='/images/logo.svg' />
                <h2>Create a new Maia account</h2>
                <ValidatedForm action='/signup.json' fields=signup_fields focus=true onSuccess=@didSignup button={className:'touch-button', text: 'Register', loading_text: 'Registering...'} />
                <Link to='/login'>Already have an account?</Link>
            </div>
        </div>

module.exports = {SignupView}
