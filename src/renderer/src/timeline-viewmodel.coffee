m             = require 'mithril'
#config        = require 'config'
util          = require 'util'
_             = require 'lodash'
TwitterClient = require './twitter-client'

REFRESH_PERIOD =
  home     : 80 * 1000
  favorite : 100 * 1000
  search   : 6 * 1000

# TODO : refactor
class TimelineItem
  constructor : (tweet) ->
    tweet.isVisible = true
    @tweet = m.prop tweet

  # TODO : refactor
  @filter : (items, word) =>
    r = new RegExp word, "i"
    for item in items()
      if item.tweet().text.match(r) then item.tweet().isVisible = true
      else if item.tweet().user.name.match(r) then item.tweet().isVisible = true
      else if item.tweet().user.screen_name.match(r) then item.tweet().isVisible = true
      else item.tweet().isVisible = false

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
    @fetchItems {count:50}, "home"
    @fetchItems {count:50}, "favorite"


  init : ->

  _setPlaceholder : (ch) =>
    @searchBoxPlaceholder[ch] = switch ch
      when "home" then m.prop "Search home timeline"
      when "favorite" then m.prop "Search favorites"
      when "search" then m.prop "Search Twitter"
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
        #console.dir tweets
        if tweets?
          @items[ch] = m.prop @_mergeItems(@items[ch](), tweets)
        m.redraw true
      .fail (error) =>

  onTweet : =>
    @_client.postTweet {status: @tweetText()}
      .then (tweet) =>
        return unless tweet?
        @items.home = m.prop @_mergeItems(@items.home(), tweet)
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
          console.log tweet.id_str
        .fail (error) =>
    else
      @_client.getStatus item.tweet().id_str
        .then (status) =>
          destroyId = status.current_user_retweet.id_str
          @_client.destroyTweet {id: destroyId}
            .then => console.log "destroy!!"


  onInputSearchText : (channel, value) =>
    # FIXME : refactor
    search = (channel) =>
      @items[channel] = m.prop []
      @fetchItems {count : 50, q : value}, "search"

    #channel = m.route().replace("/", "")
    switch channel
      when "home", "favorite"
        TimelineItem.filter @items[channel], value
        @searchTexts[channel] = m.prop value
      when "search"
        clearTimeout @searchOnInputTimerId if @searchOnInputTimerId?
        @searchOnInputTimerId = setTimeout search.bind(this, channel), 1500
        @searchTexts[channel] = m.prop value
      else console.log "hoge"

module.exports = TimelineViewModel

