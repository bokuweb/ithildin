m      = require 'mithril'
PubSub = require 'pubsub-js'
util   = require 'util'
ipc    = require 'ipc'

class AccountsComponent
  constructor : ->
    return {
      controller : (accounts, id) ->
        #PubSub.subscribe "accounts.addButton.onclick", =>
        #  ipc.send 'authenticate-request'
        #ipc.on 'authenticate-request-reply', =>
        #  console.log "reply"

        return {
          accountOnclick : (_id) ->
            id _id
            #FIXME : refactor
            #PubSub.publish "accounts.onchange", _id
        }
      view : @_view
    }

  _view : (ctrl, accounts, id) =>
    m "div.profile-inner", [
      m "div.current", [
        m "div.avatar", [
          m "img", {src : accounts()[id()].profile_image_url}
        ]
        m "div.avatar-info", [
          m "p.avatar-name", accounts()[id()].name
          m "p.avatar-name-screen", accounts()[id()].screen_name
        ]
      ]
      m "div.accounts", [
        accounts().map (account) =>
          unless  accounts()[id()]._id is account._id
            m "div.avatar-min", [
              m "a[href='#']", {onclick : ctrl.accountOnclick.bind this, account._id}, [
                m "img", {src : account.profile_image_url}
              ]
            ]
        m "div.add-account", [
          m "i.fa.fa-plus-square", {
            onclick : => ipc.send 'authenticate-request'
          }
        ]
      ]
    ]

module.exports = AccountsComponent

