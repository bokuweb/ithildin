m      = require 'mithril'
PubSub = require 'pubsub-js'
ipc    = require 'ipc'

class AccountsManager
  constructor : ->
    @_activeAccountId = 0
    PubSub.subscribe "accounts.addButton.onclick", =>
      ipc.send 'authenticate-request'

      ipc.on 'authenticate-request-reply', =>
        console.log "reply"

    PubSub.subscribe "accounts.account.onclick", (msg, _id) =>
      console.log _id

module.exports = AccountsManager

