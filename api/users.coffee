somata = require 'somata'
express = require 'express'
auth = require './auth'
crypto = require 'crypto'
{log} = somata.helpers
_ = require 'underscore'
jwt = require 'jwt-simple'

#uploads = require './uploads'
config = require '../config'
announce = require 'nexus-announce'

somata_client = new somata.Client
DataService = somata_client.bindRemote 'maia:data'
EngineService = somata_client.bindRemote 'maia:engine'
EmailService = somata_client.bindRemote 'maia:email'

module.exports = app = express()

# User accounts
# ==============================================================================

app.post '/signup.json', (req, res) ->

    new_user =
        email: req.body.email.toLowerCase().trim()
        password: auth.hashPassword req.body.password

    DataService 'signupUser', new_user, (err, created_user) ->
        if err
            log.w "[POST /signup] Failed signup: #{ new_user.email }", new_user: new_user
            res.json
                success: false
                error: err
        else
            log.s "[POST /signup] User signed up: #{ created_user.email }", user: created_user
            token = jwt.encode({_id: created_user._id}, config.auth.jwt.secret)
            announce 'maia:signup', {user: created_user}

            res.json
                success: true
                user: created_user
                token: token

app.post '/login/check.json', (req, res) ->
    if user = res.locals.user and res.locals.user.username == req.body.username
        token = jwt.encode({_id: user._id}, config.auth.jwt.secret)
        res.json
            success: true
            user: res.locals.user
            token: token
    else
        res.status 401
        res.json
            success: false

app.post '/login.json', (req, res) ->
    email = req.body.email.trim()
    password = auth.hashPassword req.body.password

    success = (user) ->
        log.s "[POST /login] User logged in: #{ user.email }", user: user
        token = jwt.encode({_id: user._id}, config.auth.jwt.secret)
        announce 'maia:login', {user}

        req.session.user_id = user._id
        req.session.save ->

            res.json
                success: true
                user: user
                token: token

    failure = (error) ->
        log.w "[POST /login] Failed login for #{ email }"
        res.status 401
        res.json
            success: false
            error: error

    DataService 'loginUser', email, password, (err, response) ->
        if err?
            failure err
        else
            success response

app.get '/logout', (req, res) ->
    req.session.destroy ->
        res.redirect '/'

app.post '/users/:user_id/token.json', auth.isThisUser, (req, res) ->
    user_id = req.params.user_id
    source = req.body.source || 'apn'
    device = req.body.device
    EngineService 'registerNotificationToken', user_id, source, device, (err, updated) ->
        res.json updated

app.post '/users/:user_id/password.json', auth.isThisUser, (req, res) ->
    fail = (error) ->
        res.json
            success: false
            error: error

    user_query =
        _id: req.params.user_id
        password: auth.hashPassword req.body.old_password

    DataService 'getUser', user_query, (err, user) ->
        if user?
            password_update =
                password: auth.hashPassword req.body.new_password
            DataService 'updateUser', req.params.user_id, password_update, (err, updated) ->
                res.json
                    success: true
                    user: updated
        else
            fail 'Password is incorrect'

app.put '/users/:user_id.json', auth.isThisUser, (req, res) ->

    # TODO: Move into helpers (but how to get res in there? middleware that attaches a res.fail fn?)
    fail = (error) ->
        res.json
            success: false
            error: error

    updateAndSucceed = (attributes) ->
        DataService 'updateUser', req.params.user_id, attributes, (err, updated) ->
            res.json
                success: true
                updated: updated

    # Upload the avatar if it exists, then update
    if req.files?.avatar?.size > 0 and (avatar_ext = uploads.file_ext req.files.avatar.name) in uploads.img_exts

        # Create the filename as [username].[timestamp].[ext]
        current_timestamp = new Date().getTime()
        avatar_filename = [req.params.user_id, current_timestamp, avatar_ext].join('.')

        # Save that image
        uploads.move_file req.files.avatar.path, avatar_filename, (err, uploaded_avatar_filename) ->

            console.log err if err
            console.log "Uploaded avatar with path:" + uploaded_avatar_filename

            # Save saved-to URL as user's new avatar
            updateAndSucceed avatar: uploaded_avatar_filename

    else if req.body.email?
        # TODO: Check email validity
        # TODO: Send confirmation email?
        updateAndSucceed email: req.body.email

    # Nothing to update
    else
        fail 'Nothing to update'


# post to this with an email... it sets a reset
# token on the user with that email and sends a link to the email
app.post '/forgot.json', (req, res) ->

    # Create the reset token
    reset_token = crypto.randomBytes(16).toString('hex')
    reset_link = config.api.base_url + '/reset/' + reset_token

    DataService 'getUser', email: req.body.email.toLowerCase(), (err, user) ->

        if !user
            res.json
                success: false
                errors: ['Could not identify your account.']

        else
            # Save the token
            DataService 'updateUser', user._id, reset_token: reset_token, (err, updated) ->
                console.log '[ERROR] ' + err if err

                # Send the email
                EmailService 'sendResetPassword', user, reset_link, (err, success) ->
                    console.log '[ERROR] ' + err if err
                res.json success: true

app.post '/reset/:reset_token.json', (req, res) ->

    DataService 'getUser', {reset_token: req.params.reset_token}, (err, user) ->

        errors = {}
        if !user
            show_forgot req, res
        if req.body.email != user.email
            errors['email'] = 'Please make sure your email is correct'
            # TODO: Keep track of suspicious things like this
        if !req.body.password
            errors['password'] = 'Please enter a password.'
        if req.body.password != req.body.confirm_password
            errors['confirm_password'] = 'Please make sure the passwords match.'

        # Display errors
        if _.keys(errors).length
            res.json
                success: false
                errors: errors

        # Success case
        else
            user_update = password: auth.hashPassword req.body.password
            DataService 'updateUser', user._id, user_update, (err, updated) ->
                res.json success: true

