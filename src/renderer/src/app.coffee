m               = require 'mithril'
jsonfile        = require 'jsonfile'
Timeline        = require './js/timeline'
Search          = require './js/search'
SideMenu        = require './js/sidemenu-component'
Twitter         = require './js/twitter-client'
AccountsManager = require './js/accounts-manager'


class IthildinRendererMain
  constructor : ->
    m.route.mode = "hash"
    # FIXME
    timeline = new Timeline()
    search =  new Search()
    m.route document.getElementById("timeline"), "/", {
      "/"       : timeline
      "/search" : search
    }

    accounts = jsonfile.readFileSync 'accounts.json'

    m.mount document.getElementById("side-menu"), m.component new SideMenu
      account :
        accounts : accounts
        activeId : 0

new IthildinRendererMain()
