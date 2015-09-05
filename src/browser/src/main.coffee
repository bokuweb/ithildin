app           = require 'app'
BrowserWindow = require 'browser-window'
jsonfile      = require 'jsonfile'
ipc           = require 'ipc'
_             = require 'lodash'
Auth          = require './auth'

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
    auth = new Auth()
    auth.request()
      .then (account) ->
        accounts.push account unless  _.includes(_.map(accounts, 'id'), account.id) 
        jsonfile.writeFile accountFile, accounts,  (err) -> loadMainWindow()
      .fail (error) -> authenticate()

  ipc.on 'authenticate-request', (event, arg) =>
    #authenticate()

  if accounts[0]?.accessToken? and accounts[0]?.accessTokenSecret?
    loadMainWindow()
  else
    authenticate()



