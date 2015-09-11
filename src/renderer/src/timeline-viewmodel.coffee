m             = require 'mithril'
config        = require 'config'
util          = require 'util'
_             = require 'lodash'
TwitterClient = require './twitter-client'

REFRESH_PERIOD =
  home     : 80 * 1000
  favorite : 100 * 1000
  search   : 6 * 1000

class TimelineItem
  constructor : (tweet) ->
    tweet.isVisible = true
    @tweet = m.prop tweet

  @filter : (items, word) =>
    r = new RegExp word, "i"
    for item in items()
      if item.tweet().text.match(r) then item.tweet().isVisible = true
      else if item.tweet().user.name.match(r) then item.tweet().isVisible = true
      else if item.tweet().user.screen_name.match(r) then item.tweet().isVisible = true
      else item.tweet().isVisible  = false

class TimelineViewModel
  constructor : (account) ->
    @_client = new TwitterClient account.accessToken, account.accessTokenSecret
    @tweetText = m.prop ""
    @searchBoxPlaceholder = {}
    @searchTexts = {}
    @items = {}
    @refreshTimerId = {}
    for channel in timelineChannels
      @items[channel] = m.prop []
      @refreshTimerId[channel] = null
      @searchTexts[channel] = m.prop ""
      @_setPlaceholder channel

    # TODO : refactor
    @fetchItems {count:10}, "home"
    @fetchItems {count:10}, "favorite"

  init : ->

  _setPlaceholder : (ch) =>
    switch ch
      when "home" then @searchBoxPlaceholder[ch] = m.prop "Search home timeline"
      when "favorite" then @searchBoxPlaceholder[ch] = m.prop "Search favorites"
      when "search" then @searchBoxPlaceholder[ch] = m.prop "Search Twitter"
      else 

  _mergeItems : (items, tweets) ->
    ids = for item in items then item.tweet().id_str
    newItems = []
    for tweet in tweets when not _.includes(ids, tweet.id_str)
      newItems.push new TimelineItem(tweet)
    newItems.concat items

  _setRefleshTimer : (params, ch) =>
    clearTimeout @refreshTimerId[ch] if @refreshTimerId[ch]?
    @refreshTimerId[ch] = setTimeout =>
      @fetchItems params, ch
    , REFRESH_PERIOD[ch]

  fetchItems : (params, ch) =>
    @_setRefleshTimer params, ch
    fetch = switch ch
      when "home"     then @_client.getHomeTimeline
      when "favorite" then @_client.getFavorites
      when "search"   then @_client.searchTweet
      else
    fetch params
      .then (tweets) =>
        return unless tweets?
        @items[ch] = m.prop @_mergeItems(@items[ch](), tweets)
        m.redraw()
      .fail (error) =>

  onTweet : =>
    @_client.postTweet {status: @tweetText()}
      .then (tweet) =>
        return unless tweet?
        @items.home = m.prop @_mergeItems(@items.home(), tweets)
        m.redraw()
      .fail (error) =>
      @tweetText ""

  onFavorite : (item) =>
    item.tweet().favorited = not item.tweet().favorited
    if item.tweet().favorited
      @_client.crateFavorite {id: item.tweet().id_str}
        .then ->
    else
      @_client.destroyFavorite {id: item.tweet().id_str}
        .then ->

  onRetweet : (item) =>
    item.tweet().retweeted = not item.tweet().retweeted
    if item.tweet().retweeted
      @_client.postRetweet {id: item.tweet().id_str}
        .then (tweet) =>
          # TODO : get new item id retweeted and set arg to desroy request
          console.log tweet.id_str
        .fail (error) =>
    else
      # TODO : get new item id retweeted and set arg to desroy request
      console.log "destroy"
      #@_client.destroyTweet, {id: item.tweet().retweetedId}


  onInputSearchText : (value) =>
    # FIXME : refactor
    channel = m.route().replace("/", "")

    search = (channel) =>
      switch channel
        when "home", "favorite"
          TimelineItem.filter @items[channel], value
          m.redraw()
        when "search"
          @items[channel] = m.prop []
          @fetchItems {count : 10, q : value}, "search"
        else console.log "hoge"

    clearTimeout @searchOnInputTimerId if @searchOnInputTimerId?
    @searchOnInputTimerId = setTimeout search.bind(this, channel), 10
    @searchTexts[channel] = m.prop value

module.exports = TimelineViewModel

