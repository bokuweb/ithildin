BrowserWindow = require 'browser-window'
TwitterApi    = require 'node-twitter-api'
config        = require 'config'
Q             = require 'q'
util          = require 'util'


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
      if error
        console.log error
        d.reject error

      url = @twitter.getAuthUrl requestToken
      loginWindow = new BrowserWindow
        width  : 800
        height : 600

      loginWindow.webContents.on 'will-navigate', (event, url) =>
        event.preventDefault()
        matched = url.match /\?oauth_token=([^&]*)&oauth_verifier=([^&]*)/
        if matched
          @twitter.getAccessToken requestToken, requestTokenSecret, matched[2], (error, accessToken, accessTokenSecret) =>
            if error then d.reject error
            else
              @twitter.verifyCredentials accessToken, accessTokenSecret, (error, profile, response) =>
                if error then d.reject error
                else
                  setTimeout ->
                    loginWindow.close()
                    loginWindow = null
                  , 0
                  profile.accessToken = accessToken
                  profile.accessTokenSecret = accessTokenSecret
                  d.resolve profile

      loginWindow.webContents.session.clearStorageData {}, =>
        loginWindow.loadUrl url
    d.promise


module.exports = Auth
