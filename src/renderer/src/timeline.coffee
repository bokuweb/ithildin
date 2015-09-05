m          = require 'mithril'
jsonfile   = require 'jsonfile'
config     = require 'config'
Twitter    = require 'twitter'
util       = require 'util'
_          = require 'lodash'
PubSub     = require 'pubsub-js'
Shell      = require 'shell'
ipc        = require 'ipc'
#velocity   = require 'velocity-animate'


class TimelineItem
  constructor : (data) ->
    @text = m.prop data.text
    @profileImage = m.prop data.user.profile_image_url
    @name = m.prop data.user.name
    @screenName = m.prop data.user.screen_name
    @createdAt = m.prop data.created_at
    @id = m.prop data.id_str
    @urls = m.prop data.entities.urls
    @isFavorited = m.prop data.favorited

class TimelineViewModel
  constructor : ->
    accounts = jsonfile.readFileSync 'accounts.json'
    @client = new Twitter
      consumer_key: config.consumerKey
      consumer_secret: config.consumerSecret
      access_token_key: accounts[0].accessToken
      access_token_secret: accounts[0].accessTokenSecret
    PubSub.subscribe "menu.home.onclick", =>
      @items = m.prop []
      m.redraw()
      @getItems()

    PubSub.subscribe "menu.favorite.onclick", =>
      @items = m.prop []
      m.redraw()
      @getFavItems()

  init : ->
    @items = m.prop []
    @getItems()
    @tweetText = m.prop ""

  getItems : =>
    @client.get 'statuses/home_timeline', {}, (error, tweets, response) =>
      ids = for item in @items() then item.id() 
      items = []
      for tweet in tweets when not _.includes(ids, tweet.id_str)
        items.push new TimelineItem tweet 
      clearTimeout @timerid if @timerid?
      @items = m.prop items.concat @items()
      @timerid = setTimeout =>
        @getItems()
      , 65000
      m.redraw()

  # TODO : refactor
  getFavItems : =>
    @client.get 'favorites/list', {}, (error, tweets, response) =>
      ids = for item in @items() then item.id() 
      items = []
      for tweet in tweets when not _.includes(ids, tweet.id_str)
        items.push new TimelineItem tweet 
      clearTimeout @timerid if @timerid?
      @items = m.prop items.concat @items()
      #@timerid = setTimeout =>
      #  @getFavItems()
      #, 65000
      m.redraw()

  tweet : =>
    @client.post 'statuses/update', {status: @tweetText()}, (error, tweet, response) =>
      if error then console.log util.inspect(error)
      else
        items = []
        items.push new TimelineItem tweet
        @items = m.prop items.concat @items()
        m.redraw()
    @tweetText ""

  createFavorite : (item) ->
    console.log "id = #{item.id()}"
    item.isFavorited = m.prop(not item.isFavorited())
    if item.isFavorited()
      @client.post 'favorites/create', {id: item.id()}, (error) => console.log util.inspect(error)
    else
      @client.post 'favorites/destroy', {id: item.id()}, (error) => console.log util.inspect(error)

  covertToRelativeTime : (createdAt) ->
    diffTime_sec = parseInt (new Date() - new Date(createdAt)) / 1000
    diffTime_day = parseInt(diffTime_sec / (60 * 60 * 24))
    diffTime_hour = parseInt(diffTime_sec / (60 * 60))
    diffTime_minuite  = parseInt(diffTime_sec / 60)
    if diffTime_day then "#{diffTime_day}d"
    else if diffTime_hour then "#{diffTime_hour}h"
    else if diffTime_minuite then "#{diffTime_minuite}m"
    else "#{diffTime_sec}s"

class Timeline
  constructor : (el) ->
    ipc.send 'authenticate-request', "hoge"
    @vm = new TimelineViewModel()
    m.mount document.getElementById(el),
      controller : => @vm.init()
      view : @view

  view : =>
    openExternal = (href) -> Shell.openExternal href

    decorateText = (text) ->
      strs =  text.split /(https?:\/\/\S+|\s\#\S+)/
      for str in strs
        if str.match(/https?:\/\/\S+/)
          m "a[href='#']", { onclick : openExternal.bind this, str}, str
        else if  str.match(/^\#/)
          m "a[href='#']", { onclick : openExternal.bind this, str}, str
        else m "span", unescape(str)

    m "div.mdl-grid",  [
      m "div.mdl-layout__drawer-button", [m "i.material-icons", "menu"]
      m "div.mdl-cell.mdl-cell--12-col", [
        m "div.mdl-textfield.mdl-js-textfield", {config : @_upgradeMdl }, [
          m "textarea.mdl-textfield__input[type='text'][rows=4]",
            oninput : m.withAttr "value", @vm.tweetText
            value : @vm.tweetText()
          m "label.mdl-textfield__label", "What's happening?"
        ]
        m "div.mdl-grid.tweet-button-wrapper", [
          m "span.tweet-length", 140 - @vm.tweetText().length
          m "button.mdl-button.mdl-js-button.mdl-button--raised.mdl-js-ripple-effect.mdl-button--accent.tweet-button", {
             onclick : @vm.tweet
            }, [
            m "i.fa.fa-twitter"
          ], "tweet"
        ]
      ]
      m "div.timeline-wrapper", [
        m "div.timeline", @vm.items().map (item) =>
          m "div.mdl-grid.item.animated.fadeInUp", [
            m "div.mdl-cell.mdl-cell--1-col", [
              m "img.avatar", {src:item.profileImage()}
            ]
            m "div.mdl-cell.mdl-cell--10-col", [
              m "span.name", item.name()
              m "span.screen-name", "@#{item.screenName()}"
              #m "span.time", @vm.covertToRelativeTime item.createdAt()
              m "span.time", new Date item.createdAt()
              m "p.text",
                if item.urls()? then decorateText item.text()
                else item.text()
              m "i.fa.fa-reply"
              m "i.fa.fa-star",
                class : if item.isFavorited() then "on" else ""
                onclick : @vm.createFavorite.bind @vm, item
              m "i.fa.fa-retweet"
            ]
          ]
      ]
    ]

  _upgradeMdl : (el, isInit, ctx) =>
    componentHandler.upgradeDom() unless isInit

module.exports = Timeline

