m            = require 'mithril'
util         = require 'util'
Tweetbox     = require './tweetbox-component'
TimelineBody = require './timelinebody-component'


class TimelineComponent
  constructor : ->
    return {
      controller : (vm, params) =>
         vm[params.accountId()].init()
      view : @_view
    }

  _view : (ctrl, vm, params) =>
    m "div.mdl-grid",  [
      m.component new Tweetbox(), {
          searchText : vm[params.accountId()].searchTexts[params.channel]
          tweetText : vm[params.accountId()].tweetText
          onTweet : vm[params.accountId()].onTweet
          onInputSearchText : vm[params.accountId()].onInputSearchText
          searchBoxPlaceholder : vm[params.accountId()].searchBoxPlaceholder[params.channel]
        }

      m.component new TimelineBody(), {
          items : vm[params.accountId()].items[params.channel]
          onFavorite : vm[params.accountId()].onFavorite
          onRetweet : vm[params.accountId()].onRetweet
        }
    ]

module.exports = TimelineComponent

