BracketMatcher = require './bracket-matcher'

describe "BracketMatcher", ->
  [editor, buffer, bracketMatcher] = []

  beforeEach ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    bracketMatcher = BracketMatcher.new(editor)

  describe "matching bracket highlighting", ->

    describe "when the cursor is before a starting bracket", ->
      it "includes the matching bracket after it", ->
        buffer.setText("asdf[qwer]zxcv")
        expect(
          bracketMatcher.enclosingRange(new Point([0, 4]))
        ).toEqual new Range([0, 4], [0, 10])

    describe "when the cursor is after a starting bracket", ->
      it "includes the matching bracket after it", ->
        buffer.setText("asdf(qwer)zxcv")
        bracketMatcher.enclosingRange(new Point([0, 5]))

    describe "when the cursor is before an ending bracket", ->
      it "includes the matching bracket before it", ->
        buffer.setText("asdf{qwer}zxcv")
        bracketMatcher.enclosingRange(new Point([0, 9]))

    describe "when the cursor is after an ending bracket", ->
      it "includes the matching bracket before it", ->
        buffer.setText("asdf(qwer)zxcv")
        bracketMatcher.enclosingRange(new Point([0, 10]))

    describe "when the cursor is between two starting brackets", ->
      it "includes the matching bracket after it for the right bracket", ->
        buffer.setText("asdf([qwer])zxcv")
        bracketMatcher.enclosingRange(new Point([0, 5]))

    describe "when the cursor is between two ending brackets", ->
      it "includes the matching bracket before it for the right bracket", ->
        buffer.setText("asdf[{qwer}]zxcv")
        bracketMatcher.enclosingRange(new Point([0, 11]))

    describe "when the cursor is between an ending bracket and a starting bracket", ->
      it "includes the matching bracket after it for the right bracket", ->
        buffer.setText("asdf[qwer][zxcv]")
        bracketMatcher.enclosingRange(new Point([0, 10]))

    # bracket pairing error
    describe "when the cursor is between a starting bracket and an ending bracket", ->
      it "includes the matching bracket after it for the left bracket", ->
        buffer.setText("asdf{[qwer](}zxcv)")
        bracketMatcher.enclosingRange(new Point([0, 12]))

    describe "when the cursor is not next to any brackets", ->
      it "includes matching brackets before and after", ->
        buffer.setText("asdf(qwer)zxcv")
        bracketMatcher.enclosingRange(new Point([0, 7]))

    describe "when there are extra pairs of the same brackets" ->
      it "ignores the extra pairs of brackets", ->
        buffer.setText("asdf((qwer)zxcv)")
        bracketMatcher.enclosingRange(new Point([0, 12]))

    describe "when there are extra pairs of different brackets"->
      it "ignores the extra pairs of brackets", ->
        buffer.setText("asdf[{qwer}zxcv]")
        bracketMatcher.enclosingRange(new Point([0, 12]))
