m            = require 'mithril'
jsonfile     = require 'jsonfile'
config       = require 'config'
Twitter      = require 'twitter'
util         = require 'util'
_            = require 'lodash'
PubSub       = require 'pubsub-js'
Tweetbox     = require './tweetbox-component'
TimelineBody = require './timelinebody-component'

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

    @items = m.prop []
    @getItems()

    #FIXME : refactor
    #PubSub.subscribe "menu.favorite.onclick", =>
    #  @items = m.prop []
    #  m.redraw()
    #  @getFavItems()
    # 
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
    @tweetText = m.prop ""
    console.log "init"

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

  createFavorite : (item) =>
    item.tweet().favorited = not item.tweet().favorited
    if item.tweet().favorited
      @client.post 'favorites/create', {id: item.tweet().id_str}, (error) => console.log util.inspect(error)
    else
      @client.post 'favorites/destroy', {id: item.tweet().id_str}, (error) => console.log util.inspect(error)

  createRetweet : (item) =>
    item.tweet().retweeted = not item.tweet().retweeted
    if item.tweet().retweeted
      @client.post 'statuses/retweet', {id: item.tweet().id_str}, (error, tweet) =>
        if error then console.log util.inspect(error)
        else
          newItem = item.tweet()
          newItem.retweetedId = tweet.id_str
          item.tweet newItem
          console.log tweet.id_str
    else
      console.log "desroy"
      # TODO
      @client.post 'statuses/destroy', {id: item.tweet().retweetedId}, (error) => console.log util.inspect(error)
      
class HomeTimeline
  constructor : ->
    @_vm = new TimelineViewModel()
    return {
      controller : => @_vm.init()
      view : @_view
    }

  _view : =>
    m "div.mdl-grid",  [
      m.component new Tweetbox
        tweetText : @_vm.tweetText
        tweet     : @_vm.tweet

      m.component new TimelineBody
        items          : @_vm.items
        createFavorite : @_vm.createFavorite
        createRetweet  : @_vm.createRetweet
    ]

module.exports = HomeTimeline

