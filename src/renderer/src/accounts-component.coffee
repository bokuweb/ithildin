m      = require 'mithril'
PubSub = require 'pubsub-js'
ipc    = require 'ipc'

class AccountsComponent
  constructor : ->
    return {
      controller : (accounts, id) ->
        PubSub.subscribe "accounts.addButton.onclick", =>
          ipc.send 'authenticate-request'

        ipc.on 'authenticate-request-reply', =>
          console.log "reply"

        return {
          accountOnclick : (_id) ->
            id _id
            #FIXME : refactor
            #PubSub.publish "accounts.onchange", _id
        }
      view : @_view
    }

  _view : (ctrl, accounts, id) =>
    m "div.mdl-grid", [
      m "div.mdl-cell.mdl-cell--3-col", [
        m "img.avatar", {src : accounts()[id()].profile_image_url}
      ]
      m "div.mdl-cell.mdl-cell--9-col", [
        m "span.profile-name", accounts()[id()].name
        m "br"
        m "span.profile-screen-name", accounts()[id()].screen_name
      ]
      m "div.mdl-grid.accounts", [
        accounts().map (account) =>
          unless  accounts()[id()]._id is account._id
            m "div.mdl-cell.mdl-cell--3-col", [
              m "a[href='#']", {onclick : ctrl.accountOnclick.bind this, account._id}, [
                m "img.avatar-mini", {src : account.profile_image_url}
              ]
            ]
        m "div.mdl-cell.mdl-cell--3-col", [
          m "i.fa.fa-plus-square.add-account", {
            onclick : => PubSub.publish "accounts.addButton.onclick"
          }
        ]
      ]
    ]

module.exports = AccountsComponent

