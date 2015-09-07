util = require 'util'
_ = require 'underscore'
orm = require './orm'

{capitalize, summarize} = require './helpers'

# General
# ------------------------------------------------------------------------------

module.exports = (schema) ->
    data_methods = {}

    # Get, Create, Update, and Remove methods for each type in the schema
    Object.keys(schema).map (__type) ->
        _type = schema[__type]
        _types = _type.collection
        _Type = capitalize _type.singular
        _Types = capitalize _type.collection

        data_methods['get' + _Type] = (query, cb) ->
            for qk, qv of query
                if qk.match /_id$/
                    query[qk] = orm.oid qv
            console.log "[get#{ _Type }]", summarize query
            _type.findOne query, (err, got) ->
                console.log "[get#{ _Type }] ERROR #{err}" if err
                cb err, got

        data_methods['find' + _Types] = (query, cb) ->
            for qk, qv of query
                if qk.match /_id$/
                    qv = orm.oid qv
            console.log "[find#{ _Types }]", summarize query
            _type.findArray query, cb

        data_methods['get' + _Types] = (query, cb) ->
            _type.findArray query, {sort: {_id: 1}}, cb

        data_methods['create' + _Type] = (item, cb) ->
            _type.insert item, (err, inserted) ->
                console.log 'error', err if err?
                console.log "[create#{ _Type }]", summarize inserted
                cb err, inserted[0]

        data_methods['update' + _Type] = (item_id, item, cb) ->
            delete item['_id']
            _type.findAndModify {_id: orm.oid item_id},
                {$set: item}, {new: true}, cb

        data_methods['remove' + _Type] = (item_id, cb) ->
            _type.remove {_id: orm.oid item_id}, cb
            
    return data_methods

