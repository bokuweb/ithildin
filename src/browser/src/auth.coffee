BrowserWindow = require 'browser-window'
TwitterApi    = require 'node-twitter-api'
config        = require 'config'
Q             = require 'q'

loginWindow = null

class Auth
  constructor : ->
    @twitter = new TwitterApi
      callback       : 'http://example.com'
      consumerKey    : config.consumerKey
      consumerSecret : config.consumerSecret

  request : ->
    d = Q.defer()
    @twitter.getRequestToken (error, requestToken, requestTokenSecret) =>
      console.log  requestToken
      if error
        console.log error
        d.reject error
        return

      url = @twitter.getAuthUrl requestToken
      loginWindow = new BrowserWindow
        width: 800
        height: 600

      loginWindow.webContents.on 'will-navigate', (event, url) =>
        event.preventDefault()
        matched = url.match /\?oauth_token=([^&]*)&oauth_verifier=([^&]*)/
        if matched
          @twitter.getAccessToken requestToken, requestTokenSecret, matched[2], (error, accessToken, accessTokenSecret) =>
            if error then d.reject error
            else
              loginWindow.close()
              loginWindow = null
              d.resolve
                accessToken : accessToken
                accessTokenSecret : accessTokenSecret

      loginWindow.loadUrl url
    d.promise


module.exports = Auth
