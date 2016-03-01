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
    bracketStack = []
    if charAfter in LEFT_BRACKETS
      leftBracket = charAfter
      rightBracket = LTR_BRACKET_MAP[leftBracket]
      leftBracketPos = cursorPoint
      rightSearchRange = new Range(leftBracketPos.traverse([0, 1]), [Infinity, 0])
      # looking for the right bracket
      @editor.scanInBufferRange new RegExp('[\\' + rightBracket + '\\' + leftBracket + ']'), rightSearchRange,
        ({matchText, range, stop}) =>
          if matchText is leftBracket
            bracketStack.push matchText
          else if matchText is rightBracket and bracketStack.pop
            rightBracketPos = range.end
            stop()
    else if charAfter in RIGHT_BRACKETS
      rightBracket = charAfter
      leftBracket = RTL_BRACKET_MAP[rightBracket]
      rightBracketPos = cursorPoint.traverse([0, 1])
      leftSearchRange = new Range([0, 0], rightBracketPos.traverse([0, -1]))
      @editor.backwardsScanInBufferRange new RegExp('\\' + leftBracket), leftSearchRange,
        ({range, stop}) =>
          leftBracketPos = range.start
          stop()
    else if charBefore in RIGHT_BRACKETS
      rightBracket = charBefore
      leftBracket = RTL_BRACKET_MAP[rightBracket]
      rightBracketPos = cursorPoint
      leftSearchRange = new Range([0, 0], rightBracketPos.traverse([0, -1]))
      @editor.backwardsScanInBufferRange new RegExp('\\' + leftBracket), leftSearchRange,
        ({range, stop}) =>
          leftBracketPos = range.start
          stop()
    else
      leftSearchRange = new Range([0, 0], cursorPoint)
      rightSearchRange = new Range(cursorPoint, [Infinity, 0])
      @editor.backwardsScanInBufferRange /[\(\[\{]/, leftSearchRange,
        ({matchText, range, stop}) =>
          leftBracket = matchText
          leftBracketPos = range.start
          stop()
      rightBracket = LTR_BRACKET_MAP[leftBracket]
      @editor.scanInBufferRange new RegExp('\\' + rightBracket), rightSearchRange,
        ({range, stop}) =>
          rightBracketPos = range.end
          stop()

    console.log leftBracketPos + rightBracketPos
    return new Range(leftBracketPos, rightBracketPos)
