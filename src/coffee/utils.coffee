CONS_START  = 0x3131
CONS_END    = 0x314E
VOWEL_START = 0x314F
VOWEL_END   = 0x3163
SYL_START   = 0xAC00
SYL_END     = 0xD7A3

# consonant offsets are compounding, so each must be decremented further
# from their corresponding invalid double consonant Final
CONS_NOT_FINALS   = [0x3138, 0x3143, 0x3149]
CONS_NOT_INITIALS = [0x3133, 0x3135, 0x3136, 0x313A, 0x313B, 0x313C, 0x313D,
                     0x313E, 0x313F, 0x3140, 0x3144]

inRange = (num, start, end) -> num >= start && num <= end

isJamoVowel = (jamo) -> inRange(jamo.charCodeAt(0), VOWEL_START, VOWEL_END)

isJamoConsonant = (jamo) -> inRange(jamo.charCodeAt(0), CONS_START, CONS_END)

getInitial = (syl) ->
  initConsNum = Math.floor((syl.charCodeAt(0) - SYL_START) / 588)
  consCode = initConsNum + CONS_START
  consCode++ for uninitial in CONS_NOT_INITIALS when uninitial <= consCode
  String.fromCharCode(consCode)

# Super simple, but commonly used predicate
startsWithVowel = (syl) ->
  getInitial(syl) == "ㅇ"

# Returns null if repl is not a valid initial consonant
replaceInitial = (syl, repl) ->
  null if not isJamoConsonant(repl) or repl.charCodeAt(0) in CONS_NOT_INITIALS
  initConsNum = Math.floor((syl.charCodeAt(0) - SYL_START) / 588)
  consDiff = initConsNum - repl.charCodeAt(0)
  String.fromCharCode(syl.charCodeAt(0) + (consDiff * 588))

getVowel = (syl) ->
  vowelNum = Math.floor(((syl.charCodeAt(0) - SYL_START) % 588) / 28)
  String.fromCharCode(vowelNum + VOWEL_START)

hasFinal = (syl) -> (syl.charCodeAt(0) - SYL_START) % 28 != 0

getFinal = (syl) ->
  if hasFinal(syl)
    finalConsNum = (syl.charCodeAt(0) - SYL_START) % 28 - 1
    consCode = finalConsNum + CONS_START
    consCode++ for unfinal in CONS_NOT_FINALS when unfinal <= consCode
    String.fromCharCode(consCode)
  else null

dropFinal = (syl) ->
  finalConsNum = (syl.charCodeAt(0) - SYL_START) % 28
  String.fromCharCode(syl.charCodeAt(0) - finalConsNum)

# Necessary for integrating with the rest of the es6-based project outside Wanakana
# coffeelint: disable=no_backticks
`export {isJamoVowel, isJamoConsonant, getInitial, startsWithVowel, replaceInitial,
         getVowel, hasFinal, getFinal, dropFinal}`
