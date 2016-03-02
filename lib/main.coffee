BlockHighlightPlugin = require './prototype-block-highlight-plugin'

module.exports =
  activate: ->
    atom.workspace.observeTextEditors (editor) ->
      plugin = new BlockHighlightPlugin(editor)
