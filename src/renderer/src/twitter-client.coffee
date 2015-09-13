Q       = require 'q'
Twitter = require 'twitter'
util    = require 'util'
#config  = require 'config'
remote  = require 'remote'

class TwitterClient
  constructor : (accessToken, accessTokenSecret) ->
    @_client = new Twitter
      consumer_key        : remote.getGlobal('consumerKey')
      consumer_secret     : remote.getGlobal('consumerSecret')
      access_token_key    : accessToken
      access_token_secret : accessTokenSecret

  getHomeTimeline : (params) =>
    d = Q.defer()
    @_client.get 'statuses/home_timeline', params, (error, tweets, response) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve tweets
    d.promise

  getFavorites : (params) =>
    d = Q.defer()
    @_client.get 'favorites/list', params, (error, tweets, response) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve tweets
    d.promise

  getStatus : (id) =>
    d = Q.defer()
    @_client.get 'statuses/show', {id : id, include_my_retweet : true}, (error, status, response) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve status
    d.promise

  getProfile : (params) =>
    d = Q.defer()
    @_client.get 'account/verify_credentials', params, (error, account, response) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve account
    d.promise

  crateFavorite : (params) =>
    d = Q.defer()
    @_client.post 'favorites/create', params, (error) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve()
    d.promise

  destroyFavorite : (params) =>
    d = Q.defer()
    @_client.post 'favorites/destroy', params, (error) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve()
    d.promise

  searchTweet  : (params) =>
    d = Q.defer()
    @_client.get 'search/tweets', params, (error, tweets, response) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve tweets.statuses
    d.promise


  searchTweet  : (params) =>
    d = Q.defer()
    @_client.get 'search/tweets', params, (error, tweets, response) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve tweets.statuses
    d.promise

  postTweet : (params) =>
    d = Q.defer()
    @_client.post 'statuses/update', params, (error, tweet, response) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve tweet
    d.promise

  postRetweet : (params) =>
    d = Q.defer()
    @_client.post 'statuses/retweet', params, (error, tweet) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve tweet
    d.promise

  destroyTweet : (params) =>
    d = Q.defer()
    @_client.post 'statuses/destroy', params, (error) =>
      if error
        console.log util.inspect(error)
        d.reject error
      d.resolve()
    d.promise

module.exports = TwitterClient
