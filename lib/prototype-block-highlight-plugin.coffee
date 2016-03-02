PrototypeBlockHighlightPluginView = require './prototype-block-highlight-plugin-view'
BracketMatcher = require './bracket-matcher'
{CompositeDisposable, Range, Point} = require 'atom'

module.exports = PrototypeBlockHighlightPlugin =
  prototypeBlockHighlightPluginView: null
  modalPanel: null
  subscriptions: null
  markers: []

  activate: (state) ->
    @prototypeBlockHighlightPluginView = new PrototypeBlockHighlightPluginView(state.prototypeBlockHighlightPluginViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @prototypeBlockHighlightPluginView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'prototype-block-highlight-plugin:toggle': => @toggle()

    atom.workspace.observeTextEditors (editor) =>
      @refreshBlockHighlight(editor)
      @subscriptions.add editor.onDidChangeSelectionRange @refreshBlockHighlight.bind(@, editor)

  resetMarkers: ->
    for decoration in @markers
      decoration.destroy()
      decoration = null
    @markers = []

  refreshBlockHighlight: (editor) ->
    @resetMarkers()

    {start, end} = editor.getSelectedBufferRange()
    return if not start.isEqual end

    enclosingRange = new BracketMatcher(editor).enclosingRange(end)
    return if not enclosingRange?

    marker = editor.markBufferRange enclosingRange
    decoration = editor.decorateMarker(marker, {type: 'highlight', class: 'block-highlight'})
    @markers.push marker

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
