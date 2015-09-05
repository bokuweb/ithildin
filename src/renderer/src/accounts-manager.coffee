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
        
module.exports = AccountsManager

