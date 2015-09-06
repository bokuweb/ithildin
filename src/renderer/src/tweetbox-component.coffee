m = require 'mithril'

class TweetBoxComponent
  constructor : (@_args) ->
    return {
      controller : ->
        return {
          _upgradeMdl : (el, isInit, ctx) =>
            componentHandler.upgradeDom() unless isInit
        }
      view : @_view
    }

  _view : (ctrl) =>
    m "div.mdl-cell.mdl-cell--12-col", [
      m "div.mdl-layout__drawer-button", [m "i.material-icons", "menu"]
      m "div.mdl-cell.mdl-cell--12-col", [
        m "div.mdl-textfield.mdl-js-textfield", {config : ctrl._upgradeMdl }, [
          m "textarea.mdl-textfield__input[type='text'][rows=4]",
            oninput : m.withAttr "value", @_args.tweetText
            value : @_args.tweetText()
          m "label.mdl-textfield__label", "What's happening?"
        ]
        m "div.mdl-grid.tweet-button-wrapper", [
          m "span.tweet-length", 140 - @_args.tweetText().length
          m "button.mdl-button.mdl-js-button.mdl-button--raised.mdl-js-ripple-effect.mdl-button--accent.tweet-button", {
             onclick : @_args.tweet
            }, [
            m "i.fa.fa-twitter"
          ], "tweet"
        ]
      ]
    ]

module.exports = TweetBoxComponent

