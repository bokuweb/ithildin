m               = require 'mithril'
jsonfile        = require 'jsonfile'
PubSub          = require 'pubsub-js'
Timeline        = require './js/timeline'
HomeTimeline    = require './js/hometimeline-component'
Search          = require './js/search-component'
Favorite        = require './js/favorite-component'
SideMenu        = require './js/sidemenu-component'
Twitter         = require './js/twitter-client'
AccountsManager = require './js/accounts-manager'


class IthildinMain
  constructor : ->
    m.route.mode = "hash"
    @_activeId = m.prop 0

    accounts = m.prop jsonfile.readFileSync 'accounts.json'
    @_timeline = for account in accounts() then new Timeline(account)

    # FIXME
    homeTimeline = new HomeTimeline @_timeline, @_activeId
    search       = new Search @_timeline, @_activeId
    favorite     = new Favorite @_timeline, @_activeId

    m.route document.getElementById("timeline"), "/home", {
      "/home"     : homeTimeline
      "/favorite" : favorite
      "/search"   : search
    }

    m.mount document.getElementById("side-menu"), m.component new SideMenu
      account :
        accounts : accounts
        activeId : @_activeId

    PubSub.subscribe "accounts.onchange", (msg, id) =>
      @_activeId id

new IthildinMain()
