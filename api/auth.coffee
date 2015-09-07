crypto = require 'crypto'
bcrypt = require 'bcrypt'
config = require '../config'

hashPassword = (password) -> bcrypt.hashSync(password, config.auth.bcrypt_salt)

randomString = (len=8) ->
    s = ''
    while s.length < len
        s += Math.random().toString(36).slice(2, len-s.length+2)
    return s

isThisUser = (req, res, next) ->
    if res.locals.user?.id == req.params.user_id
        next()
    else
        res.send 401

module.exports = {
    hashPassword
    randomString
    isThisUser
}
