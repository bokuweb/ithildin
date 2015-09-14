m                 = require 'mithril'
jsonfile          = require 'jsonfile'
ipc               = require 'ipc'
remote            = require 'remote'
TimelineViewModel = require './js/timeline-viewmodel'
TimelineComponent = require './js/timeline-component'
SideMenu          = require './js/sidemenu-component'

global.timelineChannels = ["home", "favorite", "search"]

class IthildinMain
  constructor : ->
    m.route.mode = "hash"
    accountId = m.prop 0
    @_accounts = m.prop jsonfile.readFileSync remote.getGlobal('accountFilePath')
    @_timelineViewModels = for account in @_accounts() then new TimelineViewModel(account)
    timelineComponents = {}

    for channel in timelineChannels
      timelineComponents[channel] =
        m.component new TimelineComponent(), @_timelineViewModels, {
          accountId : accountId
          channel   : channel
        }

    m.route document.getElementById("timeline"), "/home", {
      "/home"     : timelineComponents.home
      "/favorite" : timelineComponents.favorite
      "/search"   : timelineComponents.search
    }

    sidemenu = m.component new SideMenu(), @_accounts, accountId
    m.mount document.getElementById("side-menu"), sidemenu

    ipc.on 'authenticate-request-reply', (accounts) =>
      @_accounts accounts
      @_addAccount accounts[accounts.length-1]

  _addAccount : (account) =>
    @_timelineViewModels.push new TimelineViewModel(account)
    m.redraw()

new IthildinMain()
