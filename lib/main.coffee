BlockHighlightPlugin = require './block-highlight-plugin'

module.exports =
  activate: ->
    atom.workspace.observeTextEditors (editor) ->
      plugin = new BlockHighlightPlugin(editor)
