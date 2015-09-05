m               = require 'mithril'
jsonfile        = require 'jsonfile'
Timeline        = require './js/timeline'
SideMenu        = require './js/sidemenu-component'
Twitter         = require './js/twitter-client'
AccountsManager = require './js/accounts-manager'


class IthildinRendererMain
  constructor : ->
    new Timeline "timeline"
    # FIXME : temp
    new AccountsManager()
    accounts = jsonfile.readFileSync 'accounts.json'

    m.mount document.getElementById("side-menu"), m.component new SideMenu
      account :
        accounts : m.prop accounts
        activeId : 0

#      account :
#        accounts : m.prop accounts[0].profile_image_url
#        name : m.prop accounts[0].name
#        screenName : m.prop accounts[0].screen_name


new IthildinRendererMain()
