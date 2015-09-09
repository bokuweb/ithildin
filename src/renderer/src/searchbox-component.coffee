m = require 'mithril'

class SearchBoxComponent
  constructor : (args) ->
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
          m "input#sample6.mdl-textfield__input[type=text]"
          m "label.mdl-textfield__label[for=sample6]", [
            m "i.fa.fa-search.search-icon"
          ], "  Search Twitter"
        ]
      ]
    ]

module.exports = SearchBoxComponent

