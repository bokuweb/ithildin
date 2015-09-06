m          = require 'mithril'
jsonfile   = require 'jsonfile'
config     = require 'config'
Twitter    = require 'twitter'
util       = require 'util'
_          = require 'lodash'
PubSub     = require 'pubsub-js'
Shell      = require 'shell'
moment     = require 'moment'

class Search
  constructor : ->

    return {
      controller : =>
      view : @_view
    }

  _view : =>
    m "div.mdl-grid",  [
      m "span", "search component"
    ]

module.exports = Search


