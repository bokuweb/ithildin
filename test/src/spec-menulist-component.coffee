m                 = require 'mithril'
assert            = require 'power-assert'
mq                = require 'mithril-query'
MenuListComponent = require '../src/renderer/js/menulist-component'

describe "MenuListComponent view test", ->

  it "test", ->
    menu = new MenuListComponent()
    View = mq(menu.view)
    assert(View.has("nav.demo-navigation"))

