m          = require 'mithril'
jsonfile   = require 'jsonfile'
config     = require 'config'
Twitter    = require 'twitter'
util       = require 'util'

class TimelineItem
  constructor : (data) ->
    @text = m.prop data.text
    @profileImage = m.prop data.user.profile_image_url
    @name = m.prop data.user.name
    @screenName = m.prop data.user.screen_name
    @createdAt = m.prop data.created_at
    @id = m.prop data.id_str
    @urls = m.prop data.entities.urls
    @isFavorited = m.prop false

class TimelineViewModel
  constructor : ->
    token = jsonfile.readFileSync 'access_token.json'
    @client = new Twitter
      consumer_key: config.consumerKey
      consumer_secret: config.consumerSecret
      access_token_key: token.accessToken
      access_token_secret: token.accessTokenSecret

  init : ->
    @items = m.prop []
    @getItems()
    @tweetText = m.prop ""

  getItems : =>
    @client.get 'statuses/home_timeline', {count:200}, (error, tweets, response) =>
      items = []
      items.push new TimelineItem tweet for tweet in tweets
      @items = m.prop items.concat @items()
      clearTimeout @timerid if @timerid?
      console.log "update"
      @timerid = setTimeout =>
        @getItems()
      , 90000
      m.redraw()

  tweet : =>
    @client.post 'statuses/update', {status: @tweetText()}, (error, tweet, response) =>
      if error then console.log util.inspect(error)
      else
        console.log tweet.text
        items = []
        items.push new TimelineItem tweet
        @items = m.prop items.concat @items()
        console.log @items().length
        m.redraw()
    @tweetText ""

  createFavorite : (item) ->
    console.log "id = #{item.id()}"
    item.isFavorited not item.isFavorited()
    if item.isFavorited 
      @client.post 'favorites/create', {id: item.id()}, (error) => console.log util.inspect(error)
    else
      @client.post 'favorites/destroy', {id: item.id()}, (error) => console.log util.inspect(error)

  covertToRelativeTime : (createdAt) ->
    diffTime_sec = parseInt (new Date() - new Date(createdAt)) / 1000
    diffTime_day = parseInt(diffTime_sec / (60 * 60 * 24))
    diffTime_hour = parseInt(diffTime_sec / (60 * 60))
    diffTime_minuite  = parseInt(diffTime_sec / 60)
    if diffTime_day then "#{diffTime_day}日前"
    else if diffTime_hour then "#{diffTime_hour}時間前"
    else if diffTime_minuite then "#{diffTime_minuite}分前"
    else "#{diffTime_sec}秒前"

class Timeline
  constructor : (el) ->
    @vm = new TimelineViewModel()
    m.mount document.getElementById(el),
      controller : => @vm.init()
      view : @view

  view : =>

    openExternal = (href) ->
      shell = require 'shell'
      console.log "str" + href
      shell.openExternal href

    decorateText = (text) ->
      strs =  text.split /(https?:\/\/\S+)/
      for str in strs
        if str.indexOf("http") isnt -1
          m "a[href='#']", { onclick : openExternal.bind this, str}, str
        else m "span", str

    m "div.mdl-grid",  [
      m "div.mdl-cell.mdl-cell--12-col", [
        m "div.mdl-textfield.mdl-js-textfield", {config : @_upgradeMdl }, [
          m "textarea.mdl-textfield__input[type='text'][rows=4]",
            oninput : m.withAttr "value", @vm.tweetText
            value : @vm.tweetText()
          m "label.mdl-textfield__label", "いまどうしてる？"
        ]
        m "div.mdl-grid.tweet-button-wrapper", [
          m "span.tweet-length", 140 - @vm.tweetText().length
          m "button.mdl-button.mdl-js-button.mdl-button--raised.mdl-js-ripple-effect.mdl-button--accent.tweet-button", {
             onclick : @vm.tweet
            }, [
            m "i.fa.fa-twitter"
          ], "ツイート"
        ]
      ]
      m "div.timeline-wrapper", [
        m "div.timeline", @vm.items().map (item) =>
          m "div.mdl-grid.item.animated.fadeInDown", [
            m "div.mdl-cell.mdl-cell--1-col", [
              m "img.avatar", {src:item.profileImage()}
            ]
            m "div.mdl-cell.mdl-cell--10-col", [
              m "span.name", item.name()
              m "span.screen-name", "@#{item.screenName()}"
              m "span.time", @vm.covertToRelativeTime item.createdAt()
              m "p.text",
                if item.urls()?
                  decorateText item.text()
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

new Timeline "timeline"

