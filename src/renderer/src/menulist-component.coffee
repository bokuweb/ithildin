m      = require 'mithril'
PubSub = require 'pubsub-js'

class MenuListComponent
  constructor : ->
    return {
      view : @_view
    }

  _view : (controller) =>
    m "nav.demo-navigation.mdl-navigation", [
      m "a.[href='#'].menu-link", {
        class : if m.route() is "/home" then "active" else ""
      }, [m "i.fa.fa-home"], "Home"
      m "a.[href='#/favorite'].menu-link", {
        class : if m.route() is "/favorite" then "active" else ""
      }, [m "i.fa.fa-star"], "Favorite"
      m "a.[href='#/search'].menu-link", {
        class : if m.route() is "/search" then "active" else ""
      }, [m "i.fa.fa-search"], "Search"
    ]

module.exports = MenuListComponent

