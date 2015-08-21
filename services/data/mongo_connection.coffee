mongo = require 'mongodb'
config = require '../../config'

local =
    db: null
    oid: mongo.ObjectID

_db = new mongo.Db(
        config.mongo.db,
        mongo.Server(config.mongo.host, 27017),
        safe: true
    )

ensure_indexes = (db) ->
    # TODO: run into problems that can be fixed by indexing

_db.open (err, db) ->
    throw err if err
    local.db = db
    ensure_indexes db

module.exports = local

