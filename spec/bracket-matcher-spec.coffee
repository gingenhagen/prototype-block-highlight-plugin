BracketMatcher = require '../lib/bracket-matcher'
{Range, Point} = require 'atom'

describe "BracketMatcher", ->
  [editor, buffer, bracketMatcher] = []

  beforeEach ->

    waitsForPromise ->
      atom.workspace.open()

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      buffer = editor.getBuffer()
      bracketMatcher = new BracketMatcher(editor)

  describe "enclosingRange", ->

    describe "when the cursor is before a starting bracket", ->
      it "includes the matching bracket after it", ->
        buffer.setText("asdf[qwer]zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 4]
        ).toEqual new Range [0, 4], [0, 10]

      it 'ignores extra pairs of brackets', ->
        buffer.setText("asdf[q[w]er]zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 4]
        ).toEqual new Range [0, 4], [0, 12]

    describe "when the cursor is after a starting bracket", ->
      it "includes the matching bracket after it", ->
        buffer.setText("asdf(qwer)zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 5]
        ).toEqual new Range [0, 4], [0, 10]

      it 'ignores extra pairs of brackets', ->
        buffer.setText("asdf(q(w)er)zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 5]
        ).toEqual new Range [0, 4], [0, 12]

    describe "when the cursor is before an ending bracket", ->
      it "includes the matching bracket before it", ->
        buffer.setText("asdf{qwer}zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 9]
        ).toEqual new Range [0, 4], [0, 10]

      it 'ignores extra pairs of brackets', ->
        buffer.setText("asdf{q{w}er}zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 11]
        ).toEqual new Range [0, 4], [0, 12]

    describe "when the cursor is after an ending bracket", ->
      it "includes the matching bracket before it", ->
        buffer.setText("asdf(qwer)zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 10]
        ).toEqual new Range [0, 4], [0, 10]

      it 'ignores extra pairs of brackets', ->
        buffer.setText("asdf(qw(e)r)zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 12]
        ).toEqual new Range [0, 4], [0, 12]

    describe "when the cursor is between two starting brackets", ->
      it "includes the matching bracket after it for the right bracket", ->
        buffer.setText("asdf([qwer])zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 5]
        ).toEqual new Range [0, 5], [0, 11]

      it 'ignores extra pairs of brackets', ->
        buffer.setText("asdf([q[w]er])zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 5]
        ).toEqual new Range [0, 5], [0, 13]

    describe "when the cursor is between two ending brackets", ->
      it "includes the matching bracket before it for the right bracket", ->
        buffer.setText("asdf[{qwer}]zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 11]
        ).toEqual new Range [0, 4], [0, 12]

      it 'ignores extra pairs of brackets', ->
        buffer.setText("asdf[{qw[e]r}]zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 13]
        ).toEqual new Range [0, 4], [0, 14]

    describe "when the cursor is between an ending bracket and a starting bracket", ->
      it "includes the matching bracket after it for the right bracket", ->
        buffer.setText("asdf[qwer][zxcv]")
        expect(
          bracketMatcher.enclosingRange [0, 10]
        ).toEqual new Range [0, 10], [0, 16]

      it 'ignores extra pairs of brackets', ->
        buffer.setText("asdf[qwer][zx[c]v]")
        expect(
          bracketMatcher.enclosingRange [0, 10]
        ).toEqual new Range [0, 10], [0, 18]

    describe "when the cursor is between a starting bracket and an ending bracket", ->
      it "includes the matching bracket after it for the left bracket", ->
        buffer.setText("asdf{[qwer](}zxcv)")
        expect(
          bracketMatcher.enclosingRange [0, 12]
        ).toEqual new Range [0, 11], [0, 18]

      it 'ignores extra pairs of brackets', ->
        buffer.setText("asdf{[qwer](}zx(c)v)")
        expect(
          bracketMatcher.enclosingRange [0, 12]
        ).toEqual new Range [0, 11], [0, 20]

    describe "when the cursor is not next to any brackets", ->
      it "includes matching brackets before and after", ->
        buffer.setText("asdf(qwer)zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 8]
        ).toEqual new Range [0, 4], [0, 10]

      it 'ignores extra pairs of brackets that are the same', ->
        buffer.setText("asdf(q(w)er)zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 10]
        ).toEqual new Range [0, 4], [0, 12]

      it "ignores extra pairs of brackets that are different", ->
        buffer.setText("asdf[q{w}er]zxcv")
        expect(
          bracketMatcher.enclosingRange [0, 10]
        ).toEqual new Range [0, 4], [0, 12]
