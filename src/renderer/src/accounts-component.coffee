m      = require 'mithril'
PubSub = require 'pubsub-js'
ipc    = require 'ipc'

# FIXME : seperate
class AccountsVieModel
  constructor : (args) ->
    @activeId = m.prop args.activeId
    @accounts = m.prop args.accounts

    PubSub.subscribe "accounts.addButton.onclick", =>
      ipc.send 'authenticate-request'

    ipc.on 'authenticate-request-reply', =>
      console.log "reply"

  accountOnclick : (_id) ->
    @activeId _id
    #FIXME : refactor
    PubSub.publish "accounts.onchange", _id

class AccountsComponent
  constructor : (args) ->
    @_vm = new AccountsVieModel args

    return {
      controller : =>
      view : @_view
    }

  _view : =>
    m "div.mdl-grid.animated.fadeIn", [
      m "div.mdl-cell.mdl-cell--3-col", [
        m "img.avatar", {src : @_vm.accounts()[@_vm.activeId()].profile_image_url}
      ]
      m "div.mdl-cell.mdl-cell--9-col", [
        m "span.profile-name", @_vm.accounts()[@_vm.activeId()].name
        m "br"
        m "span.profile-screen-name", @_vm.accounts()[@_vm.activeId()].screen_name
      ]
      m "div.mdl-grid.accounts", [
        @_vm.accounts().map (account) =>
          unless  @_vm.accounts()[@_vm.activeId()].id is account.id
            m "div.mdl-cell.mdl-cell--3-col", [
              m "a[href='#']", {onclick : @_vm.accountOnclick.bind @_vm, account._id}, [
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

