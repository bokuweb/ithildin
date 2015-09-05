m      = require 'mithril'
PubSub = require 'pubsub-js'

class AccountsComponent
  constructor : (@_args = {}) ->
    return {
      view : @_view
    }

  _view : =>
    m "div.mdl-grid.animated.fadeInDown", [
      m "div.mdl-cell.mdl-cell--3-col", [
        m "img.avatar", {src:@_args.image()}
      ]
      m "div.mdl-cell.mdl-cell--9-col", [
        m "span.profile-name", @_args.name()
        m "br"
        m "span.profile-screen-name", @_args.screenName()
      ]
      m "div.mdl-cell.mdl-cell--12-col", [
        m "i.fa.fa-plus-square.add-account", {
          onclick: => PubSub.publish "accounts.addButton.onclick"
        }
      ]
    ]

module.exports = AccountsComponent

