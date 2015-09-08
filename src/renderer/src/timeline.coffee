m             = require 'mithril'
config        = require 'config'
util          = require 'util'
_             = require 'lodash'
TwitterClient = require './twitter-client'

HOME_REFRESH_PERIOD = 65000

class TimelineItem
  constructor : (tweet) ->
    @tweet = m.prop tweet

class TimelineViewModel
  constructor : (account) ->
    @_client = new TwitterClient account.accessToken, account.accessTokenSecret
    @tweetText = m.prop ""
    @items =
      home     : m.prop []
      favorite : m.prop []
      search   : m.prop []

    @timerId =
      home     : null
      favorite : null
      search   : null

    # TODO : refactor
    @fetchHomeItems {count:200}
    @fetchFavoriteItems {}

  _mergeItems : (items, tweets) ->
    ids = for item in items then item.tweet().id_str
    newItems = []
    for tweet in tweets when not _.includes(ids, tweet.id_str)
      newItems.push new TimelineItem(tweet)
    newItems.concat items

  # TODO : refactor
  fetchHomeItems : (params) =>
    #FIXME
    clearTimeout @timerId.home if @timerId.home?
    @timerId.home = setTimeout =>
      @fetchHomeItems params
    , HOME_REFRESH_PERIOD

    @_client.getHomeTimeline params
      .then (tweets) =>
        return unless tweets?
        @items.home = m.prop @_mergeItems(@items.home(), tweets)
        m.redraw()
      .fail (error) =>

  fetchFavoriteItems : (params) =>
    #FIXME
    clearTimeout @timerId.favorite if @timerId.favorite?
    @timerId.favorite = setTimeout =>
      @fetchHomeItems params
    , HOME_REFRESH_PERIOD

    @_client.getFavorites params
      .then (tweets) =>
        return unless tweets?
        @items.favorite = m.prop @_mergeItems(@items.favorite(), tweets)
        m.redraw()
      .fail (error) =>

  fetchSearchItems : (params) =>
    #FIXME
    clearTimeout @timerId.search if @timerId.search?
    @timerId.search = setTimeout =>
      @fetchSearchItems params
    , HOME_REFRESH_PERIOD

    @_client.searchTweet params
      .then (tweets) =>
        return unless tweets?
        @items.search = m.prop @_mergeItems(@items.search(), tweets)
        m.redraw()
      .fail (error) =>

  onTweet : =>
    @_client.postTweet {status: @tweetText()}
      .then (tweet) =>
        return unless tweet?
        @items.home = m.prop @_mergeItems(@items.home(), tweets)
        @tweetText ""
        m.redraw()
      .fail (error) => @tweetText ""

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

module.exports = TimelineViewModel

