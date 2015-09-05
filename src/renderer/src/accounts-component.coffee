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
        m "img.avatar", {src:@_args.accounts()[@_args.activeId].profile_image_url}
      ]
      m "div.mdl-cell.mdl-cell--9-col", [
        m "span.profile-name", @_args.accounts()[@_args.activeId].name
        m "br"
        m "span.profile-screen-name", @_args.accounts()[@_args.activeId].screen_name
      ]
      m "div.mdl-grid.accounts", [
        @_args.accounts().map (account) => m "div.mdl-cell", [
          m "img.avatar-mini", {src:account.profile_image_url}
        ]
        m "div.mdl-cell", [
          m "i.fa.fa-plus-square.add-account", {
            onclick: => PubSub.publish "accounts.addButton.onclick"
          }
        ]
      ]
    ]

module.exports = AccountsComponent

