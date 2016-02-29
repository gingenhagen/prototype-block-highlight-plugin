PrototypeBlockHighlightPluginView = require './prototype-block-highlight-plugin-view'
{CompositeDisposable} = require 'atom'

module.exports = PrototypeBlockHighlightPlugin =
  prototypeBlockHighlightPluginView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @prototypeBlockHighlightPluginView = new PrototypeBlockHighlightPluginView(state.prototypeBlockHighlightPluginViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @prototypeBlockHighlightPluginView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'prototype-block-highlight-plugin:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @prototypeBlockHighlightPluginView.destroy()

  serialize: ->
    prototypeBlockHighlightPluginViewState: @prototypeBlockHighlightPluginView.serialize()

  toggle: ->
    console.log 'PrototypeBlockHighlightPlugin was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
