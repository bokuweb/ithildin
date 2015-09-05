m      = require 'mithril'
PubSub = require 'pubsub-js'
ipc    = require 'ipc'

class AccountsManager
  constructor : ->
    PubSub.subscribe "accounts.addButton.onclick", =>
      console.log "account add button click"
      ipc.send 'authenticate-request'

module.exports = AccountsManager

