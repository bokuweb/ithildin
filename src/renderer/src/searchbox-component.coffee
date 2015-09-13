m      = require 'mithril'
pubsub = require 'pubsub-js'

class SearchBoxComponent
  constructor : ->
    return {
      controller : (args) ->
        return {
          _upgradeMdl : (el, isInit, ctx) =>
            componentHandler.upgradeDom() unless isInit
        }
      view : @_view
    }

  _view : (ctrl, args) =>
    m "div#search-box", [
      m "div.mdl-textfield.mdl-js-textfield", {config : ctrl._upgradeMdl }, [
        m "label.mdl-button.mdl-js-button.mdl-button--icon[for=sample6]"
        m "div.mdl-textfield", [
          m "input#sample6.mdl-textfield__input[type=text]",
            oninput : m.withAttr "value", args.onInputSearchText.bind this, args.channel
            value :   args.searchText()
          m "label.mdl-textfield__label[for=sample6]", [
            m "i.fa.fa-search.search-icon"
          ], "  #{args.searchBoxPlaceholder()}"
        ]
        #m "button.mdl-button.mdl-js-button.mdl-button--raised.mdl-js-ripple-effect.mdl-button--accent.search-button", {
        #  onclick : args.onInputSearchText
        #}, [m "i.fa.fa-search"]
      ]
    ]

module.exports = SearchBoxComponent

