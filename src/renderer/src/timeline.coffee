m            = require 'mithril'
config       = require 'config'
Twitter      = require 'twitter-client'
util         = require 'util'
_            = require 'lodash'

HOME_REFRESH_PERIOD = 65000

class TimelineItem
  constructor : (tweet) -> @tweet = m.prop tweet

class TimelineViewModel
  constructor : (account) ->
    @_client = new Twitter
      access_token_key    : account.accessToken
      access_token_secret : account.accessTokenSecret

    @items =
      home     : m.prop []
      favorite : m.prop []
      search   : m.prop []

    # TODO : refactor
    @fetchHomeItems()
    @fetchFavoriteItems()

  init : ->
    @tweetText = m.prop ""

  _mergeItems : (items, tweets) ->
    ids = for item in items then item.tweet().id_str
    new TimelineItem tweet for tweet in tweets when not _.includes(ids, tweet.id_str)

  # TODO : refactor
  fetchHomeItems : (params) =>
    #FIXME
    clearTimeout @timerid.home if @timerid.home?
    @timerid.home = setTimeout =>
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
    clearTimeout @timerid.favorite if @timerid.favorite?
    @timerid.favorite = setTimeout =>
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
    clearTimeout @timerid.search if @timerid.search?
    @timerid.search = setTimeout =>
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
        .fail (error) =>
    else
      @_client.destroyFavorite {id: item.tweet().id_str}
        .then ->
        .fail (error) =>

  onRetweet : (item) =>
    item.tweet().retweeted = not item.tweet().retweeted
    if item.tweet().retweeted
      @_client.postRetweet, {id: item.tweet().id_str}
        .then (tweet) =>
          # TODO : get new item id retweeted and set arg desroy request
          console.log tweet.id_str
        .fail (error) =>
    else
      # TODO : get new item id retweeted and set arg desroy request
      console.log "destroy"
      #@_client.destroyTweet, {id: item.tweet().retweetedId}

module.exports = TimelineViewModel

