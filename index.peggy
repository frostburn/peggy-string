String
  = '"' chars: DoubleStringCharacter* '"' { return chars.join(''); }
  / "'" chars: SingleStringCharacter* "'" { return chars.join(''); }

DoubleStringCharacter
  = $(!(["\\] / LineTerminator) SourceCharacter)
  / '\u2028'
  / '\u2029'
  / '\\' @EscapeSequence
  / LineContinuation

SingleStringCharacter
  = $(!(['\\] / LineTerminator) SourceCharacter)
  / '\u2028'
  / '\u2029'
  / '\\' @EscapeSequence
  / LineContinuation

LineContinuation
  = '\\' LineTerminatorSequence { return ''; }

EscapeSequence
  = CharacterEscapeSequence
  / '0' !DecimalDigit { return '\0'; }
  / HexEscapeSequence
  / UnicodeEscapeSequence

CharacterEscapeSequence
  = SingleEscapeCharacter
  / NonEscapeCharacter

SingleEscapeCharacter
  = "'"
  / '"'
  / '\\'
  / 'b'  { return '\b'; }
  / 'f'  { return '\f'; }
  / 'n'  { return '\n'; }
  / 'r'  { return '\r'; }
  / 't'  { return '\t'; }
  / 'v'  { return '\v'; }

NonEscapeCharacter
  = $(!(EscapeCharacter / LineTerminator) SourceCharacter)

EscapeCharacter
  = SingleEscapeCharacter
  / DecimalDigit
  / 'x'
  / 'u'

HexEscapeSequence
  = 'x' digits:$(HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }

UnicodeEscapeSequence
  = 'u' digits:$(HexDigit HexDigit HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }

DecimalDigit
  = [0-9]

HexDigit
  = [0-9a-f]i

LineTerminator
  = '\n'
  / '\r'
  / '\u2028'
  / '\u2029'

LineTerminatorSequence
  = '\n'
  / '\r' !'\n'
  / '\u2028'
  / '\u2029'
  / '\r\n'

SourceCharacter 'any character'
  = SourceCharacterLow
  / SourceCharacterHigh

// Not surrogates
SourceCharacterLow
  = [\u0000-\uD7FF\uE000-\uFFFF]

// Can be properly-matched surrogates or lone surrogates.
SourceCharacterHigh
  = $([\uD800-\uDBFF][\uDC00-\uDFFF]) // Surrogate pair
  / [\uD800-\uDBFF] // Lone first surrogate
  / [\uDC00-\uDFFF] // Lone second surrogate
