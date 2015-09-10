m             = require 'mithril'
config        = require 'config'
util          = require 'util'
_             = require 'lodash'
TwitterClient = require './twitter-client'

REFRESH_PERIOD =
  home     : 80 * 1000
  favorite : 100 * 1000
  search   : 20 * 1000

class TimelineItem
  constructor : (tweet) ->
    @tweet = m.prop tweet

class TimelineViewModel
  constructor : (account) ->
    @_client = new TwitterClient account.accessToken, account.accessTokenSecret
    @tweetText = m.prop ""
    @searchText = m.prop ""
    @items = {}
    @timerId = {}
    for channel in timelineChannels
      @items[channel] = m.prop []
      @timerId[channel] = null

    # TODO : refactor
    @fetchItems {count:10}, "home"
    @fetchItems {count:200}, "favorite"

  _mergeItems : (items, tweets) ->
    ids = for item in items then item.tweet().id_str
    newItems = []
    for tweet in tweets when not _.includes(ids, tweet.id_str)
      newItems.push new TimelineItem(tweet)
    newItems.concat items

  _setRefleshTimer : (params, ch) =>
    clearTimeout @timerId[ch] if @timerId[ch]?
    @timerId[ch] = setTimeout =>
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
          # TODO : get new item id retweeted and set arg desroy request
          console.log tweet.id_str
        .fail (error) =>
    else
      # TODO : get new item id retweeted and set arg desroy request
      console.log "destroy"
      #@_client.destroyTweet, {id: item.tweet().retweetedId}

  onInputSearchText : (channel) =>
    

module.exports = TimelineViewModel

