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
                <h1>Maia</h1>
                <h2>Create a Maia account</h2>
            </div>

            <div className='login-view'>
                <ValidatedForm action='/signup.json' fields=signup_fields focus=true onSuccess=@didSignup />
            </div>
            <Link to='/login'>Already have an account?</Link>
        </div>

module.exports = {SignupView}
