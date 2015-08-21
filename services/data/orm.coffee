mongo = require './mongo_connection'
moment = require 'moment'
_ = require 'underscore'
S = require 'string'

class Collection
    @findArray: (query, options, cb) ->
        if !cb
            cb = options
            options = {}
        @find(query)
            .sort(options.sort)
            .skip(options.skip || 0)
            .limit(options.limit || 99999)
            .toArray (err, found) =>
                found = [] if !found
                cb err, (@coerce(item) for item in found)
    @find: (query) ->
        mongo.db.collection(@collection).find(query)
    @findOne: (query, cb) ->
        mongo.db.collection(@collection).findOne query, (err, found) => cb err, if found then @coerce(found) else null
    @count: (query, cb) ->
        mongo.db.collection(@collection).count query, (err, n) => cb err, n
    @insert: (item, cb) ->
        mongo.db.collection(@collection).insert item, (err, inserted) =>
            cb err, inserted.map (i) => @coerce(i)
    @update: (query, item, options, cb) ->
        if !cb
            cb = options
            options = {}
        mongo.db.collection(@collection).update(query, item, options, cb)
    @findAndModify: (query, update, options, cb) ->
        if !cb
            cb = options
            options = {}
        mongo.db.collection(@collection).findAndModify(query, null, update, options, cb)
    @save: (item, cb) ->
        mongo.db.collection(@collection).save(item, cb)
    @remove: (item, cb) ->
        mongo.db.collection(@collection).remove(item, cb)
    @ensureIndex: (index, cb) ->
        mongo.db.collection(@collection).ensureIndex(index, cb)
    @coerce: (item) -> item

class Document
    constructor: (attrs) ->
        for key, value of attrs
            @[key] = value
    # Get an associated "parent" document by looking up objects of the parent type
    # by the set [parent]_id type on this object; attach it as [parent] to the
    # current object.
    #
    # Takes an optional options hash with which the default `id_key` and
    # `child_key` can be overridden.
    get_parent: (ParentType, options, cb) ->
        if !cb
            cb = options
            options = {}
        id_key = options.id_key || ParentType.singular + '_id'
        parent_key = options.parent_key || ParentType.singular
        ParentType.findOne
            _id: @[id_key]
        , (err, parent) =>
            @[parent_key] = parent
            cb err, @
    # Get a set of associated children documents by looking up objects of the
    # children type matching [this]_id as this object's _id; attach as [children] to
    # this object.
    #
    # Takes an optional options hash with which the default `id_key`, 
    # `children_key`, `query`, `sort`, and `limit` can be overridden.
    get_children: (ChildType, options, cb) ->
        if !cb
            cb = options
            options = {}
        id_key = options.id_key || @Type.singular + '_id'
        children_key = options.children_key || ChildType.collection
        query = options.query || {}
        query[id_key] = @_id
        ChildType.findArray query, options, (err, children) =>
            @[children_key] = children
            cb err, @

    # Get the time this document was inserted by parsing the ObjectID
    createdAt: ->
        return oid_to_timestamp @_id

trimmer = (s) -> (l=300) ->
    if s.length > l
        s.slice(0, l) + '...'
    else
        s

attach_child = (Type, item, cb) ->
    id_key = Type.singular + '_id'
    Type.findOne
        _id: mongo_oid(item[id_key])
    , (err, child) ->
        item[Type.singular] = child
        cb err, item

attach_attributes = (AttributeType, ItemType, item, cb) ->
    id_key = ItemType.singular + '_id'
    query = {}
    query[id_key] = item._id
    AttributeType.findArray query, (err, attributes) ->
        item[AttributeType.collection] = attributes
        cb err, item

bulk_attach_attributes = (AttributeType, items, options, cb) ->
    if !cb
        cb = options
        options = {}

    attribute_key = options.id_key || AttributeType.singular
    id_key = attribute_key + '_id'
    search_key = options.attach_key || id_key #TODO: script change to neighborhood -> neighborhood_id and [lat, lng] to [lng, lat]
    
    item_attribute_ids = (mongo_oid(i[search_key]) for i in items)

    AttributeType.findArray
        _id: {$in: _.uniq item_attribute_ids}
    , (err, attributes) ->
        for i in [0..items.length-1]
            if not item_attribute_ids[i]
                continue
            for attribute in attributes
                if item_attribute_ids[i].equals attribute._id
                    items[i][attribute_key] = attribute
                    break
        cb err, items

mongo_oid = (s) ->
    if s && typeof s == 'string'
        return mongo.oid s
    else
        return s

oid_to_timestamp = (id) ->
    parseInt(id.toString().substring(0, 8), 16) * 1000

module.exports =
    Collection: Collection
    Document: Document
    attach_child: attach_child
    attach_attributes: attach_attributes
    bulk_attach_attributes: bulk_attach_attributes
    oid: mongo_oid
    mongo: mongo
