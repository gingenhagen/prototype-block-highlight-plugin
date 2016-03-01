PrototypeBlockHighlightPluginView = require './prototype-block-highlight-plugin-view'
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
      @subscriptions.add editor.onDidChangeCursorPosition @handleCursor.bind(@, editor)

  resetMarkers: ->
    for decoration in @markers
      decoration.destroy()
      decoration = null
    @markers = []

  handleCursor: (editor, {newBufferPosition}) ->
    @resetMarkers()

    braceMap =
      '(': ')'
      '[': ']'
      '{': '}'

    leftBrace = rightBrace = leftBracePos = rightBracePos = null

    editor.backwardsScanInBufferRange /[\(\[\{]/, new Range([0, 0], newBufferPosition),
      ({matchText, range, stop}) =>
        # console.log range + ':' + matchText
        leftBrace = matchText
        leftBracePos = range.start
        stop()

    rightBrace = braceMap[leftBrace]
    editor.scanInBufferRange new RegExp('\\' + rightBrace), new Range(newBufferPosition, [Infinity, 0]),
      ({matchText, range, stop}) =>
        # console.log range + ':' + matchText
        rightBracePos = range.end

    # console.log leftBracePos + rightBracePos
    marker = editor.markBufferRange new Range(leftBracePos, rightBracePos)
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
