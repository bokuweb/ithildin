m      = require 'mithril'
PubSub = require 'pubsub-js'

class MenuListComponent
  constructor : (el) ->
    @_active = m.prop "home"
    return {
      view : @_view
    }

  _view : =>
    m "nav.demo-navigation.mdl-navigation", [
      m "a.[href='#'].menu-link", {
        class : if @_active() is "home" then "active" else ""
        onclick: =>
          @_active = m.prop "home"
          PubSub.publish "menu.home.onclick"
      }, [m "i.fa.fa-home"], "Home"
      m "a.[href='#'].menu-link", {
        class : if @_active() is "link" then "active" else ""
        onclick: =>
          @_active = m.prop "link"
          PubSub.publish "menu.favorite.onclick"
      }, [m "i.fa.fa-star"], "Favorite"
      m "a.[href='#'].menu-link", {
        class : if @_active() is "search" then "active" else ""
        onclick: =>
          @_active = m.prop "search"
          PubSub.publish "menu.search.onclick"
      },[m "i.fa.fa-search"], "Search"
    ]

module.exports = MenuListComponent

