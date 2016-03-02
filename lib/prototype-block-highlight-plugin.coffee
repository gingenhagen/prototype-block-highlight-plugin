BracketMatcher = require './bracket-matcher'
{CompositeDisposable, Range, Point} = require 'atom'

module.exports =
class BlockHighlightPlugin
  subscriptions: null
  markers: []

  constructor: (editor) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @subscriptions.add editor.onDidChangeSelectionRange @refreshBlockHighlight.bind(@, editor)
    @refreshBlockHighlight(editor)

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
    @markers.push marker
    decoration = editor.decorateMarker(marker, {type: 'highlight', class: 'block-highlight'})

  destory: ->
    @subscriptions.dispose()
