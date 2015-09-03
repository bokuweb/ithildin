m          = require 'mithril'
jsonfile   = require 'jsonfile'
config     = require 'config'
Twitter    = require 'twitter'
#velocity   = require 'velocity-animate'

class ProfileData
  constructor : () ->

class ProfileViewModel
  constructor : ->
    token = jsonfile.readFileSync 'access_token.json'
    @client = new Twitter
      consumer_key: config.consumerKey
      consumer_secret: config.consumerSecret
      access_token_key: token.accessToken
      access_token_secret: token.accessTokenSecret

  init : ->
    @image = m.prop ""
    @name = m.prop ""
    @screenName = m.prop ""
    @getProfiles()

  getProfiles : =>
    @client.get 'account/verify_credentials', {}, (error, account, response) =>
      @image = m.prop account.profile_image_url
      @name = m.prop account.name
      @screenName = m.prop account.screen_name

class Profile
  constructor : (el) ->
    new Menu "menu"
    @_vm = new ProfileViewModel()
    m.mount document.getElementById(el),
      controller : => @_vm.init()
      view : @_view

  _view : =>
    [
      m "div.mdl-grid.animated.fadeInDown", [
        m "div.mdl-cell.mdl-cell--3-col", [
          m "img.avatar", {src:@_vm.image()}
        ]
        m "div.mdl-cell.mdl-cell--9-col", [
          m "span.profile-name", @_vm.name()
          m "br"
          m "span.profile-screen-name", @_vm.screenName()
        ]
      ]

    ]


PubSub = require 'pubsub-js'

class Menu
  constructor : (el) ->
    @_active = m.prop "home"
    m.mount document.getElementById(el),
      view : @_view

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

module.exports = Profile

