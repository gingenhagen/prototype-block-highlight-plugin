PrototypeBlockHighlightPluginView = require './prototype-block-highlight-plugin-view'
{CompositeDisposable, Range, Point} = require 'atom'

LEFT_BRACES = ['(', '[', '{']
RIGHT_BRACES = [')', ']', '}']
LTR_BRACE_MAP =
  '(': ')'
  '[': ']'
  '{': '}'
RTL_BRACE_MAP =
  ')': '('
  ']': '['
  '}': '{'

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
      @handleCursor(editor)
      @subscriptions.add editor.onDidChangeCursorPosition @handleCursor.bind(@, editor)

  resetMarkers: ->
    for decoration in @markers
      decoration.destroy()
      decoration = null
    @markers = []

  handleCursor: (editor) ->
    @resetMarkers()

    {start, end} = editor.getSelectedBufferRange()
    return if not start.isEqual end

    # if we are right before a starting brace, then we should search for the matching one
    # if we are right before an ending brace, then we should search for the matching front
    # if we are right after an ending brace, then we should search for the matching front
    # otherwise, search for unmatched braces before and after the cursor

    cursorPos = end
    charBefore = editor.getTextInBufferRange new Range(cursorPos, cursorPos.traverse([0, -1]))
    charAfter = editor.getTextInBufferRange new Range(cursorPos, cursorPos.traverse([0, 1]))

    leftBrace = rightBrace = leftBracePos = rightBracePos = leftSearchRange = rightSearchRange = null
    if charAfter in LEFT_BRACES
      leftBrace = charAfter
      rightBrace = LTR_BRACE_MAP[leftBrace]
      leftBracePos = cursorPos
      rightSearchRange = new Range(leftBracePos.traverse([0, 1]), [Infinity, 0])
      editor.scanInBufferRange new RegExp('\\' + rightBrace), rightSearchRange,
        ({range, stop}) =>
          rightBracePos = range.end
          stop()
    else if charAfter in RIGHT_BRACES
      rightBrace = charAfter
      leftBrace = RTL_BRACE_MAP[rightBrace]
      rightBracePos = cursorPos.traverse([0, 1])
      leftSearchRange = new Range([0, 0], rightBracePos.traverse([0, -1]))
      editor.backwardsScanInBufferRange new RegExp('\\' + leftBrace), leftSearchRange,
        ({range, stop}) =>
          leftBracePos = range.start
          stop()
    else if charBefore in RIGHT_BRACES
      rightBrace = charBefore
      leftBrace = RTL_BRACE_MAP[rightBrace]
      rightBracePos = cursorPos
      leftSearchRange = new Range([0, 0], rightBracePos.traverse([0, -1]))
      editor.backwardsScanInBufferRange new RegExp('\\' + leftBrace), leftSearchRange,
        ({range, stop}) =>
          leftBracePos = range.start
          stop()
    else
      leftSearchRange = new Range([0, 0], cursorPos)
      rightSearchRange = new Range(cursorPos, [Infinity, 0])
      editor.backwardsScanInBufferRange /[\(\[\{]/, leftSearchRange,
        ({matchText, range, stop}) =>
          leftBrace = matchText
          leftBracePos = range.start
          stop()
      rightBrace = LTR_BRACE_MAP[leftBrace]
      editor.scanInBufferRange new RegExp('\\' + rightBrace), rightSearchRange,
        ({range, stop}) =>
          rightBracePos = range.end
          stop()

    console.log leftBracePos + rightBracePos
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
