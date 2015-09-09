m            = require 'mithril'
Tweetbox     = require './tweetbox-component'
TimelineBody = require './timelinebody-component'


class TimelineComponent
  constructor : ->
    return {
      controller : (vm, params) =>
      view : @_view
    }

  _view : (ctrl, vm, params) =>
    m "div.mdl-grid",  [
      m.component new Tweetbox(), {
        tweetText : vm[params.accountId()].tweetText
        onTweet   : vm[params.accountId()].onTweet
      }

      m.component new TimelineBody(), {
        items      : vm[params.accountId()].items[params.channel()]
        onFavorite : vm[params.accountId()].onFavorite
        onRetweet  : vm[params.accountId()].onRetweet
      }
    ]

module.exports = TimelineComponent

