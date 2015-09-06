m          = require 'mithril'
Menulist   = require './menulist-component'
Accounts   = require './accounts-component'

class SideMenuComponent
  constructor : (args) ->
    @_accountsComponent = new Accounts args.account
    @_menuListComponent = new Menulist()

    return {
      view : @_view
    }

  _view : =>
    m "header.demo-drawer-header", [
      m "img#logo", {src:"./img/ithildin-logo.png"}
      m "div#profile", [
        m.component @_accountsComponent
      ]
      m "div#menu", [
        m.component @_menuListComponent
      ]
    ]

module.exports = SideMenuComponent

