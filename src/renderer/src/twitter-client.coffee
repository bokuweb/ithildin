Q       = require 'q'
Twitter = require 'twitter'
util    = require 'util'

class TwitterClient
  constructor : (keys) ->
    @_client = new Twitter
      consumer_key: keys.consumer_key
      consumer_secret: keys.consumer_secret
      access_token_key: keys.access_token_key
      access_token_secret: keys.access_token_secret

  getProfile : ->
    d = Q.defer()
    @_client.get 'account/verify_credentials', {}, (error, account, response) =>
      if error
        console.log util.inspect(error)
        d.reject error 
      d.resolve account
    d.promise

module.exports = TwitterClient
