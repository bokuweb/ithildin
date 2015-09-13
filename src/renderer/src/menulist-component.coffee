m      = require 'mithril'

class MenuListComponent
  constructor : ->
    @_route = m.prop "home"
    return {
      view : @_view
    }

  _view : (ctrl) =>
    m "nav.demo-navigation.mdl-navigation", [
      m "a.[href='#home'].menu-link", {
        class : if @_route() is "home" then "active" else ""
        onclick : => @_route "home"
      }, [m "i.fa.fa-home"], "Home"
      m "a.[href='#/favorite'].menu-link", {
        class : if @_route() is "favorite" then "active" else ""
        onclick : => @_route "favorite"
      }, [m "i.fa.fa-star"], "Favorite"
      m "a.[href='#/search'].menu-link", {
        class : if @_route() is "search" then "active" else ""
        onclick : => @_route "search"
      }, [m "i.fa.fa-search"], "Search"
    ]

module.exports = MenuListComponent

