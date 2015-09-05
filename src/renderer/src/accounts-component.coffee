m      = require 'mithril'
PubSub = require 'pubsub-js'

class AccountsComponent
  constructor : (args) ->
    @_activeId = m.prop args.activeId
    @_accounts = m.prop args.accounts

    return {
      view : @_view
    }

  _view : =>
    m "div.mdl-grid.animated.fadeInDown", [
      m "div.mdl-cell.mdl-cell--3-col", [
        m "img.avatar", {src : @_accounts()[@_activeId()].profile_image_url}
      ]
      m "div.mdl-cell.mdl-cell--9-col", [
        m "span.profile-name", @_accounts()[@_activeId()].name
        m "br"
        m "span.profile-screen-name", @_accounts()[@_activeId()].screen_name
      ]
      m "div.mdl-grid.accounts", [
        @_accounts().map (account) =>
          unless  @_accounts()[@_activeId()].id is account.id
            m "div.mdl-cell.mdl-cell--2-col", [
              m "img.avatar-mini", {src:account.profile_image_url}
            ]
        m "div.mdl-cell.mdl-cell--2-col", [
          m "i.fa.fa-plus-square.add-account", {
            onclick: => PubSub.publish "accounts.addButton.onclick"
          }
        ]
      ]
    ]

module.exports = AccountsComponent

