m          = require 'mithril'
Menulist   = require './menulist-component'
Accounts   = require './accounts-component'

class SideMenuComponent
  constructor : ->
    @_menu = new Menulist()
    return {
      controller : (accounts, id) ->
      view : @_view
    }

  _view : (ctrl, accounts, id) =>
    m "header.demo-drawer-header", [
      m "div.logo", [
        m "img", {src:"./img/ithildin-logo.png"}
      ]
      m "div.profile", [
        m.component new Accounts(), accounts, id
      ]
      m "div.menu", [
        m.component @_menu
      ]
    ]

module.exports = SideMenuComponent

