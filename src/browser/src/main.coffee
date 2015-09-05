app           = require 'app'
BrowserWindow = require 'browser-window'
jsonfile      = require 'jsonfile'
ipc           = require 'ipc'
_             = require 'lodash'
Auth          = require './auth'
Q             = require 'q'

mainWindow = null

app.on 'window-all-closed', -> app.quit()

app.on 'ready', ->
  loadMainWindow = ->
    mainWindow = new BrowserWindow 
      width: 1200
      height: 800
      'min-width': 638

    mainWindow.on 'closed', -> mainWindow = null
    mainWindow.loadUrl "file://#{require('path').resolve()}/src/renderer/index.html"

  accountFile = 'accounts.json'
  accounts = []
  try
    accounts = jsonfile.readFileSync accountFile

  authenticate = ->
    d = Q.defer()
    auth = new Auth()
    auth.request()
      .then d.resolve
      .fail (error) -> authenticate()
    d.promise

  ipc.on 'authenticate-request', (event, arg) =>
    authenticate().then (account) ->
      accounts.push account unless  _.includes(_.map(accounts, 'id'), account.id) 
      jsonfile.writeFile accountFile, accounts,  (err) ->
        event.sender.send 'authenticate-request-reply', accounts

  if accounts[0]?.accessToken? and accounts[0]?.accessTokenSecret?
    loadMainWindow()
  else
    authenticate().then (account) ->
      accounts.push account unless  _.includes(_.map(accounts, 'id'), account.id) 
      jsonfile.writeFile accountFile, accounts,  (err) -> loadMainWindow()



