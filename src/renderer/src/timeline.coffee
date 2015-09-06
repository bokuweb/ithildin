m          = require 'mithril'
jsonfile   = require 'jsonfile'
config     = require 'config'
Twitter    = require 'twitter'
util       = require 'util'
_          = require 'lodash'
PubSub     = require 'pubsub-js'
Shell      = require 'shell'

#velocity   = require 'velocity-animate'

class TimelineItem
  constructor : (tweet) -> @tweet = m.prop tweet

class TimelineViewModel
  constructor : ->
    accounts = jsonfile.readFileSync 'accounts.json'
    @client = new Twitter
      consumer_key: config.consumerKey
      consumer_secret: config.consumerSecret
      access_token_key: accounts[0].accessToken
      access_token_secret: accounts[0].accessTokenSecret

    #FIXME : refactor
    PubSub.subscribe "menu.home.onclick", =>
      @items = m.prop []
      m.redraw()
      @getItems()

    #FIXME : refactor
    PubSub.subscribe "menu.favorite.onclick", =>
      @items = m.prop []
      m.redraw()
      @getFavItems()

    #FIXME : refactor
    PubSub.subscribe "accounts.onchange", (msg, id) =>
      @items = m.prop []
      accounts = jsonfile.readFileSync 'accounts.json'
      @client = new Twitter
        consumer_key: config.consumerKey
        consumer_secret: config.consumerSecret
        access_token_key: accounts[id].accessToken
        access_token_secret: accounts[id].accessTokenSecret
      m.redraw()
      @getItems()

  init : ->
    @items = m.prop []
    @getItems()
    @tweetText = m.prop ""

  getItems : =>
    @client.get 'statuses/home_timeline', {}, (error, tweets, response) =>
      ids = for item in @items() then item.tweet().id_str
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
      ids = for item in @items() then item.tweet().id_str
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
    item.isFavorited = m.prop(not item.tweet().favorited)
    if item.tweet().favorited
      @client.post 'favorites/create', {id: item.tweet().id}, (error) => console.log util.inspect(error)
    else
      @client.post 'favorites/destroy', {id: item.tweet().id}, (error) => console.log util.inspect(error)

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

    @_vm = new TimelineViewModel()
    m.mount document.getElementById(el),
      controller : => @_vm.init()
      view : @_view

  _view : =>
    openExternal = (href) -> Shell.openExternal href

    htmlDecode = (text) ->
      e = document.createElement 'div'
      e.innerHTML = text
      if e.childNodes.length is 0 then "" else e.childNodes[0].nodeValue

    decorateText = (text) ->
      strs =  text.split /(https?:\/\/\S+|\s\#\S+)/
      for str in strs
        if str.match(/https?:\/\/\S+/)
          m "a[href='#']", { onclick : openExternal.bind this, str}, str
        else if str.match(/^\#|^\s\#/)
          m "a[href='#']", { onclick : openExternal.bind this, str}, str
        else m "span", htmlDecode(str)

    m "div.mdl-grid",  [
      m "div.mdl-layout__drawer-button", [m "i.material-icons", "menu"]
      m "div.mdl-cell.mdl-cell--12-col", [
        m "div.mdl-textfield.mdl-js-textfield", {config : @_upgradeMdl }, [
          m "textarea.mdl-textfield__input[type='text'][rows=4]",
            oninput : m.withAttr "value", @_vm.tweetText
            value : @_vm.tweetText()
          m "label.mdl-textfield__label", "What's happening?"
        ]
        m "div.mdl-grid.tweet-button-wrapper", [
          m "span.tweet-length", 140 - @_vm.tweetText().length
          m "button.mdl-button.mdl-js-button.mdl-button--raised.mdl-js-ripple-effect.mdl-button--accent.tweet-button", {
             onclick : @_vm.tweet
            }, [
            m "i.fa.fa-twitter"
          ], "tweet"
        ]
      ]
      m "div.timeline-wrapper", [
        m "div.timeline", @_vm.items().map (item) =>
          m "div.mdl-grid.item.animated.fadeInUp", [
            m "div.mdl-cell.mdl-cell--1-col", [
              m "img.avatar", {src:item.tweet().user.profile_image_url}
            ]
            m "div.mdl-cell.mdl-cell--10-col.tweet-body", [
              m "span.name", item.tweet().user.name
              m "span.screen-name", "@#{item.tweet().screen_name}"
              #m "span.time", @_vm.covertToRelativeTime item.createdAt()
              m "span.time", new Date item.tweet().created_at
              m "p.text",
                decorateText item.tweet().text
              if item.tweet().entities?.media?
                m "div.image-wraper", [
                  m "img.media", {src:item.tweet().entities.media[0].media_url}
                ]
              
              m "i.fa.fa-reply"
              m "i.fa.fa-star",
                class : if item.tweet().favorited then "on" else ""
                onclick : @_vm.createFavorite.bind @_vm, item
              m "i.fa.fa-retweet"
            ]
          ]
      ]
    ]

  _upgradeMdl : (el, isInit, ctx) =>
    componentHandler.upgradeDom() unless isInit

module.exports = Timeline

