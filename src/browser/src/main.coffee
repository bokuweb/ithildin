app           = require 'app'
BrowserWindow = require 'browser-window'
jsonfile      = require 'jsonfile'
Auth          = require './auth'

mainWindow = null

app.on 'window-all-closed', -> app.quit()

app.on 'ready', ->
  loadMainWindow = ->
    mainWindow = new BrowserWindow
      width: 1200
      height: 800
    mainWindow.on 'closed', -> mainWindow = null
    mainWindow.loadUrl "file://#{require('path').resolve()}/src/renderer/index.html"

  tokenFile = 'access_token.json'
  try
    token = jsonfile.readFileSync tokenFile

  if token?.accessToken? and token?.accessTokenSecret?
    loadMainWindow()
  else
    auth = new Auth()
    auth.request()
      .then (res) ->
        jsonfile.writeFile tokenFile, res,  (err) ->
          loadMainWindow()
      .fail (error) ->


