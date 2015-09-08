m            = require 'mithril'
Tweetbox     = require './tweetbox-component'
TimelineBody = require './timelinebody-component'

class FavoriteComponent
  constructor : (@_vm, @_id) ->
    return {
      controller : =>
      view : @_view
    }

  _view : =>
    m "div.mdl-grid",  [
      m.component new Tweetbox
        tweetText : @_vm[@_id()].tweetText
        onTweet   : @_vm[@_id()].onTweet

      m.component new TimelineBody
        items      : @_vm[@_id()].items.favorite
        onFavorite : @_vm[@_id()].onFavorite
        onRetweet  : @_vm[@_id()].onRetweet
    ]

module.exports = FavoriteComponent
