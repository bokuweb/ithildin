m      = require 'mithril'
PubSub = require 'pubsub-js'

active = m.prop "home"

class MenuListComponent

  constructor : ->
    return {
      view : @_view
    }

  _view : (controller) =>
    m "nav.demo-navigation.mdl-navigation", [
      m "a.[href='#'].menu-link", {
        class : if active() is "home" then "active" else ""
        onclick : =>
          active = m.prop "home"
          PubSub.publish "menu.home.onclick"
      }, [m "i.fa.fa-home"], "Home"
      m "a.[href='#'].menu-link", {
        class : if active() is "link" then "active" else ""
        onclick: =>
          active = m.prop "link"
          PubSub.publish "menu.favorite.onclick"
      }, [m "i.fa.fa-star"], "Favorite"
      m "a.[href='#'].menu-link", {
        class : if active() is "search" then "active" else ""
        onclick: =>
          active = m.prop "search"
          PubSub.publish "menu.search.onclick"
      },[m "i.fa.fa-search"], "Search"
    ]

module.exports = MenuListComponent

