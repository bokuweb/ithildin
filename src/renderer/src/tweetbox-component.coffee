m         = require 'mithril'
util      = require 'util'
SearchBox = require './searchbox-component'

class TweetBoxComponent
  constructor :  ->
    return {
      controller : (args) ->

        return {
          _upgradeMdl : (el, isInit, ctx) =>
            componentHandler.upgradeDom() unless isInit
        }
      view : @_view
    }

  _view : (ctrl, args)  =>
      m "div.action-wrapper", [
        m "div.mdl-textfield.mdl-js-textfield", {config : ctrl._upgradeMdl }, [
          m "textarea.mdl-textfield__input[type='text'][rows=4]",
            oninput : m.withAttr "value", args.tweetText
            value : args.tweetText()
          m "label.mdl-textfield__label", "What's happening?"
        ]
        m "div.aside-wrapper", [
          m "div.tweet-button-wrapper", [
            m "span.tweet-length", 140 - args.tweetText().length
            m "button.mdl-button.mdl-js-button.mdl-button--raised.mdl-js-ripple-effect.mdl-button--accent.tweet-button", {
               onclick : args.onTweet
              }, [
              m "i.fa.fa-twitter"
            ], "tweet"
          ]
          m "div.search-wrapper", [
            m.component new SearchBox(), {
                searchText : args.searchText
                onInputSearchText : args.onInputSearchText
                searchBoxPlaceholder : args.searchBoxPlaceholder
                channel : args.channel
              }
          ]
        ]
      ]

module.exports = TweetBoxComponent

