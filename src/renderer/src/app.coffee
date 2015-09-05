m        = require 'mithril'
jsonfile = require 'jsonfile'
Timeline = require './js/timeline'
SideMenu = require './js/sidemenu-component'
Twitter  = require './js/twitter-client'

new Timeline "timeline"

# FIXME : temp
accounts = jsonfile.readFileSync 'accounts.json'

m.mount document.getElementById("side-menu"), m.component new SideMenu
  account :
    image : m.prop accounts[0].profile_image_url
    name : m.prop accounts[0].name
    screenName : m.prop accounts[0].screen_name


