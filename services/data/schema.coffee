somata = require 'somata'
orm = require './orm'
async = require 'async'
_ = require 'underscore'

# Define collections

class Users extends orm.Collection
    @singular: 'user'
    @collection: 'users'
    @coerce: (item) ->
        delete item['password']
        item = new Document item
        item

class Devices extends orm.Collection
    @singular: 'device'
    @collection: 'devices'

class Measurements extends orm.Collection
    @singular: 'measurement'
    @collection: 'measurements'
    @coerce: (item) ->
        item = new Document item
        item.created_at = item.createdAt()
        item

class Subscriptions extends orm.Collection
    @singular: 'subscription'
    @collection: 'subscriptions'

module.exports = {
    Users
    Devices
    Measurements
    Subscriptions
}
