m               = require 'mithril'
jsonfile        = require 'jsonfile'
HomeTimeline    = require './js/hometimeline-component'
Search          = require './js/search'
Favorite        = require './js/favorite'
SideMenu        = require './js/sidemenu-component'
Twitter         = require './js/twitter-client'
AccountsManager = require './js/accounts-manager'


class IthildinRendererMain
  constructor : ->
    m.route.mode = "hash"
    # FIXME
    homeTimeline = new HomeTimeline()
    search =  new Search()
    favorite =  new Favorite()
    
    m.route document.getElementById("timeline"), "/", {
      "/"       : homeTimeline
      "/favorite" : favorite
      "/search" : search
    }

    accounts = jsonfile.readFileSync 'accounts.json'

    m.mount document.getElementById("side-menu"), m.component new SideMenu
      account :
        accounts : accounts
        activeId : 0

new IthildinRendererMain()
