{Range, Point} = require 'atom'

LEFT_BRACKETS = ['(', '[', '{']
RIGHT_BRACKETS = [')', ']', '}']
LTR_BRACKET_MAP =
  '(': ')'
  '[': ']'
  '{': '}'
RTL_BRACKET_MAP =
  ')': '('
  ']': '['
  '}': '{'

module.exports =
class BracketMatcher
  constructor: (editor) ->
    @editor = editor

  enclosingRange: (cursorPos) ->

    cursorPoint = Point.fromObject(cursorPos)

    charBefore = @editor.getTextInBufferRange new Range(cursorPoint, cursorPoint.traverse([0, -1]))
    charAfter = @editor.getTextInBufferRange new Range(cursorPoint, cursorPoint.traverse([0, 1]))

    # if we are right before a starting bracket, then we should search for the matching one
    # if we are right before an ending bracket, then we should search for the matching front
    # if we are right after an ending bracket, then we should search for the matching front
    # otherwise, search for unmatched brackets before and after the cursor
    leftBracket = rightBracket = leftBracketPos = rightBracketPos = leftSearchRange = rightSearchRange = null
    if charAfter in LEFT_BRACKETS
      leftBracket = charAfter
      rightBracket = LTR_BRACKET_MAP[leftBracket]
      leftBracketPos = cursorPoint
      rightSearchRange = new Range(leftBracketPos.traverse([0, 1]), [Infinity, 0])
      # looking for the right bracket
      bracketStack = []
      @editor.scanInBufferRange new RegExp('[\\' + rightBracket + '\\' + leftBracket + ']', 'g'), rightSearchRange,
        ({matchText, range, stop}) =>
          if matchText is leftBracket
            bracketStack.push matchText
          else if matchText is rightBracket and not bracketStack.pop()
            rightBracketPos = range.end
            stop()
    else if charBefore in LEFT_BRACKETS
      leftBracket = charBefore
      rightBracket = LTR_BRACKET_MAP[leftBracket]
      leftBracketPos = cursorPoint.traverse([0, -1])
      rightSearchRange = new Range(leftBracketPos.traverse([0, 1]), [Infinity, 0])
      bracketStack = []
      @editor.scanInBufferRange new RegExp('[\\' + rightBracket + '\\' + leftBracket + ']', 'g'), rightSearchRange,
        ({matchText, range, stop}) =>
          if matchText is leftBracket
            bracketStack.push matchText
          else if matchText is rightBracket and not bracketStack.pop()
            rightBracketPos = range.end
            stop()
    else if charAfter in RIGHT_BRACKETS
      rightBracket = charAfter
      leftBracket = RTL_BRACKET_MAP[rightBracket]
      rightBracketPos = cursorPoint.traverse([0, 1])
      leftSearchRange = new Range([0, 0], rightBracketPos.traverse([0, -1]))
      bracketStack = []
      @editor.backwardsScanInBufferRange new RegExp('[\\' + leftBracket + '\\' + rightBracket + ']', 'g'), leftSearchRange,
        ({matchText, range, stop}) =>
          if matchText is rightBracket
            bracketStack.push matchText
          else if matchText is leftBracket and not bracketStack.pop()
            leftBracketPos = range.start
            stop()
    else if charBefore in RIGHT_BRACKETS
      rightBracket = charBefore
      leftBracket = RTL_BRACKET_MAP[rightBracket]
      rightBracketPos = cursorPoint
      leftSearchRange = new Range([0, 0], rightBracketPos.traverse([0, -1]))
      bracketStack = []
      @editor.backwardsScanInBufferRange new RegExp('[\\' + leftBracket + '\\' + rightBracket + ']', 'g'), leftSearchRange,
        ({matchText, range, stop}) =>
          if matchText is rightBracket
            bracketStack.push matchText
          else if matchText is leftBracket and not bracketStack.pop()
            leftBracketPos = range.start
            stop()
    else
      leftSearchRange = new Range([0, 0], cursorPoint)
      bracketStack = []
      @editor.backwardsScanInBufferRange /[\(\)\[\]\{\}]/g, leftSearchRange,
        ({matchText, range, stop}) =>
          if matchText in RIGHT_BRACKETS
            bracketStack.push matchText
          else if matchText in LEFT_BRACKETS
            if bracketStack[bracketStack.length - 1] is LTR_BRACKET_MAP[matchText]
              bracketStack.pop()
            else
              leftBracket = matchText
              leftBracketPos = range.start
              stop()

      return null if not leftBracketPos?

      rightBracket = LTR_BRACKET_MAP[leftBracket]
      rightSearchRange = new Range(leftBracketPos.traverse([0, 1]), [Infinity, 0])
      bracketStack = []
      @editor.scanInBufferRange new RegExp('[\\' + leftBracket + '\\' + rightBracket + ']', 'g'), rightSearchRange,
        ({matchText, range, stop}) =>
          if matchText is leftBracket
            bracketStack.push matchText
          else if matchText is rightBracket and not bracketStack.pop()
            rightBracketPos = range.end
            stop()

    return null if not leftBracketPos? or not rightBracketPos?

    range = new Range(leftBracketPos, rightBracketPos)
    console.log range
    return range
