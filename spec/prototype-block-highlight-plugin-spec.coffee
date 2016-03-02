BlockHighlightPlugin = require '../lib/prototype-block-highlight-plugin'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "BlockHighlightPlugin", ->
  [editor, buffer] = []

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()

    waitsForPromise ->
      atom.packages.activatePackage('prototype-block-highlight-plugin')

    runs ->
      editor = atom.workspace.getActiveTextEditor()

  describe 'when the block-highlight-plugin is active', ->

    getDecorations = ->
      return editor.getHighlightDecorations().filter (decoration) -> decoration.properties.class is 'block-highlight'

    it 'highlights the current block', ->
      editor.setText("asdf[qwer]zxcv")

      editor.setCursorBufferPosition([0, 4])

      decorations = getDecorations()
      expect(decorations.length).toBe 1
      marker = decorations[0].marker
      expect(marker.getStartBufferPosition()).toEqual [0, 4]
      expect(marker.getEndBufferPosition()).toEqual [0, 10]

    it 'highlights multiple lines', ->
      editor.setText("asdf[qwer\nzxcv]")

      editor.setCursorBufferPosition([0, 4])

      decorations = getDecorations()
      expect(decorations.length).toBe 1
      marker = decorations[0].marker
      expect(marker.getStartBufferPosition()).toEqual [0, 4]
      expect(marker.getEndBufferPosition()).toEqual [1, 5]
