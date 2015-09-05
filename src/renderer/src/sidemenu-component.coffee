m          = require 'mithril'
Menulist   = require './menulist-component'
Accounts   = require './accounts-component'

class SideMenuComponent
  constructor : (@_args) ->
    return {
      view : @_view
    }

  _view : =>
    m "header.demo-drawer-header", [
      m "img#logo", {src:"./img/ithildin-logo.png"}
      m "div#profile", [
        m.component new Accounts(@_args.account)
      ]
      m "div#menu", [
        m.component new Menulist()
      ]
    ]

module.exports = SideMenuComponent

