m        = require 'mithril'
jsonfile = require 'jsonfile'
config   = require 'config'
Timeline = require './js/timeline'
SideMenu = require './js/sidemenu-component'
Twitter  = require './js/twitter-client'

new Timeline "timeline"

# FIXME : temp
token = jsonfile.readFileSync 'access_token.json'
console.log token.accessTokenSecret
console.log config.consumerKey

@_twitter = new Twitter
  consumer_key: config.consumerKey
  consumer_secret: config.consumerSecret
  access_token_key: token.accessToken
  access_token_secret: token.accessTokenSecret

@_twitter.getProfile()
  .then (account) =>
    m.mount document.getElementById("side-menu"), m.component new SideMenu
      account :
        image : m.prop account.profile_image_url
        name : m.prop account.name
        screenName : m.prop account.screen_name


