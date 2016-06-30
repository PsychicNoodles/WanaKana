# coffelint disable=no_backticks
`import {getInitial, startsWithVowel, replaceInitial, getVowel, getFinal,
         dropFinal} from './utils'`

wanakana = wanakana || {}

# version is inserted from package.json by compiler
wanakana.version = "%version%"

# Support AMD
if typeof define is "function" and define.amd
  define "wanakana", [], ->wanakana

wanakana.LOWERCASE_START = 0x61
wanakana.LOWERCASE_END   = 0x7A
wanakana.UPPERCASE_START = 0x41
wanakana.UPPERCASE_END   = 0x5A
wanakana.HIRAGANA_START  = 0x3041
wanakana.HIRAGANA_END    = 0x3096
wanakana.KATAKANA_START  = 0x30A1
wanakana.KATAKANA_END    = 0x30FA
wanakana.JAMO_START      = 0x3130
wanakana.JAMO_END        = 0x3163
wanakana.HANGEUL_START   = 0xAC00
wanakana.HANGEUL_END     = 0xD7A3

wanakana.LOWERCASE_FULLWIDTH_START = 0xFF41
wanakana.LOWERCASE_FULLWIDTH_END   = 0xFF5A
wanakana.UPPERCASE_FULLWIDTH_START = 0xFF21
wanakana.UPPERCASE_FULLWIDTH_END   = 0xFF3A

wanakana.defaultOptions =
  # Transliterates wi and we to ゐ and ゑ
  useObseleteKana: no
  # Special mode for handling input from a text input that is transliterated on the fly.
  # Japanese: allows certain situations for a lone ん
  # Korean: allows "appending" consonants/vowels to incomplete syllables and
  # pulling final consonants out to attach to lone vowels
  # (off assumes that each character is already complete)
  IMEMode: off
  # Convert hiragana to lowercase and katakana to uppercase
  convertKatakanaToUppercase: no
  # Separator for toRomaja
  separator: ''

###*
 * Automatically sets up an input field to be an IME.
###
wanakana.bindJp = (input) ->
  input.addEventListener('input', wanakana._onJpInput)

wanakana.unbindJp = (input) ->
  input.removeEventListener('input', wanakana._onJpInput)

wanakana._onJpInput = (event) ->
  input = event.target
  startingCursor = input.selectionStart
  startingLength = input.value.length
  normalizedInputString = wanakana._convertFullwidthCharsToASCII (input.value)
  newText = (wanakana.toKana(normalizedInputString, {IMEMode: true}))
  unless normalizedInputString is newText
    input.value = newText
    if (typeof input.selectionStart == "number")
      input.selectionStart = input.selectionEnd = input.value.length
    else if (typeof input.createTextRange != "undefined")
      input.focus()
      range = input.createTextRange()
      range.collapse(false)
      range.select()

wanakana.bindKr = (input) ->
  input.addEventListener('input', wanakana._onKrInput)

wanakana.unbindKr = (input) ->
  input.removeEventListener('input', wanakana._onKrInput)

wanakana._onKrInput = (event) ->
  input = event.target
  startingCursor = input.selectionStart # boy making variables sure is fun
  startingLength = input.value.length   # don't know why these are made but it's fun
  normalizedInputString = wanakana._convertFullwidthCharsToASCII (input.value)
  newText = (wanakana.toHangeul(normalizedInputString, {IMEMode: true}))
  unless normalizedInputString is newText
    input.value = newText
    if (typeof input.selectionStart == "number")
      input.selectionStart = input.selectionEnd = input.value.length
    else if (typeof input.createTextRange != "undefined")
      input.focus()
      range = input.createTextRange()
      range.collapse(false)
      range.select()

wanakana._extend = (target, source) ->
  if not target?
    return source
  for prop of source
    if not target[prop]? and source[prop]?
      target[prop] = source[prop]
  return target

# extends the target with source, overwriting existing values
# note that the order of parameters is swapped, not to be confusing but for readability
wanakana._oextend = (source, target) ->
  if not target?
    return source
  for prop of source
    unless target[prop]?
      target[prop] = source[prop]
  return target

###*
 * Takes a character and a unicode range. Returns true if the char is in the range.
###
wanakana._isCharInRange = (char, start, end) ->
  code = char.charCodeAt 0
  return start <= code <= end

wanakana._isCharVowel = (char, includeY = yes) ->
  regexp = if includeY then /[aeiouy]/ else /[aeiou]/
  return char.toLowerCase().charAt(0).search(regexp) isnt -1
wanakana._isCharConsonant = (char, includeY = yes) ->
  regexp = if includeY then /[bcdfghjklmnpqrstvwxyz]/ else /[bcdfghjklmnpqrstvwxz]/
  return char.toLowerCase().charAt(0).search(regexp) isnt -1

wanakana._isCharKatakana = (char) ->
  wanakana._isCharInRange(char, wanakana.KATAKANA_START, wanakana.KATAKANA_END)
wanakana._isCharHiragana = (char) ->
  wanakana._isCharInRange(char, wanakana.HIRAGANA_START, wanakana.HIRAGANA_END)
wanakana._isCharKana = (char) ->
  wanakana._isCharHiragana(char) or wanakana._isCharKatakana(char)
wanakana._isCharNotKana = (char) ->
  not wanakana._isCharHiragana(char) and not wanakana._isCharKatakana(char)
wanakana._isCharHangeul = (char) ->
  wanakana._isCharInRange(char, wanakana.HANGEUL_START, wanakana.HANGEUL_END)
wanakana._isCharJamo = (char) ->
  wanakana._isCharInRange(char, wanakana.JAMO_START, wanakana.JAMO_END)
wanakana._isCharKorean = (char) ->
  wanakana._isCharHangeul(char) or wanakana._isCharJamo(char)
wanakana._isCharNotKorean = (char) ->
  not wanakana._isCharHangeul(char) and not wanakana._isCharJamo(char)

wanakana._convertFullwidthCharsToASCII = (string) ->
  chars = string.split ""
  for char,i in chars
    code = char.charCodeAt(0)
    if wanakana._isCharInRange(char, wanakana.LOWERCASE_FULLWIDTH_START, wanakana.LOWERCASE_FULLWIDTH_END)
      chars[i] = String.fromCharCode(code - wanakana.LOWERCASE_FULLWIDTH_START + wanakana.LOWERCASE_START)
    if wanakana._isCharInRange(char, wanakana.UPPERCASE_FULLWIDTH_START, wanakana.UPPERCASE_FULLWIDTH_END)
      chars[i] String.fromCharCode(code - wanakana.UPPERCASE_FULLWIDTH_START + wanakana.UPPERCASE_START)

  chars.join ""

wanakana._katakanaToHiragana = (kata) ->
  hira = []
  for kataChar in kata.split ""
    if wanakana._isCharKatakana(kataChar)
      code = kataChar.charCodeAt 0
      # Shift charcode.
      code += wanakana.HIRAGANA_START - wanakana.KATAKANA_START
      hiraChar = String.fromCharCode code
      hira.push hiraChar
    else
      # pass non katakana chars through
      hira.push kataChar
  hira.join ""

wanakana._hiraganaToKatakana = (hira) ->
  kata = []
  for hiraChar in hira.split ""
    if wanakana._isCharHiragana(hiraChar)
      code = hiraChar.charCodeAt 0
      # Shift charcode.
      code += wanakana.KATAKANA_START - wanakana.HIRAGANA_START
      kataChar = String.fromCharCode code
      kata.push kataChar
    else
      # pass non hiragana chars through
      kata.push hiraChar
  kata.join ""

wanakana._hiraganaToRomaji = (hira, options) ->
  # merge options with default options
  options = wanakana._extend(options, wanakana.defaultOptions)
  len = hira.length
  roma = []
  cursor = 0
  chunkSize = 0
  maxChunk = 2

  getChunk = () -> hira.substr(cursor, chunkSize)
  # Don't pick a chunk that is bigger than the remaining characters.
  resetChunkSize = () -> chunkSize = Math.min(maxChunk, len-cursor)

  while cursor < len
    convertThisChunkToUppercase = no
    resetChunkSize()
    while chunkSize > 0
      chunk = getChunk()
      if wanakana.isKatakana(chunk)
        convertThisChunkToUppercase = options.convertKatakanaToUppercase
        chunk = wanakana._katakanaToHiragana(chunk)


      # special case for small tsus
      if chunk.charAt(0) is "っ" and chunkSize is 1 and cursor < (len-1)
        nextCharIsDoubleConsonant = true
        romaChar = ""
        break

      romaChar = wanakana.J_to_R[chunk]

      if romaChar? and nextCharIsDoubleConsonant
        romaChar = romaChar.charAt(0).concat(romaChar)
        nextCharIsDoubleConsonant = false

      # DEBUG
      # console.log (cursor + "x" + chunkSize + ":" + chunk + " => " + romaChar )
      break if romaChar?
      chunkSize--

    unless romaChar?
      # console.log("Couldn't find " + chunk + ". Passing through.")
      # Passthrough undefined values
      romaChar = chunk

    if convertThisChunkToUppercase
      romaChar = romaChar.toUpperCase()
    # Handle special cases.
    roma.push romaChar
    cursor += chunkSize or 1
  roma.join("")

wanakana._romajiToHiragana = (roma, options) -> wanakana._romajiToKana(roma, options, true)
wanakana._romajiToKana = (roma, options, ignoreCase = false) ->
  # console.log (new Date().getTime())
  # merge options with default options
  options = wanakana._extend(options, wanakana.defaultOptions)
  len = roma.length
  # Final output array
  kana = []
  # Position in the string that is being evaluated
  cursor = 0
  # Maximum size of the chunk of characters to evaluate at one time
  maxChunk = 3

  # Pulls a chunk of characters based on the cursor position and chunkSize
  getChunk = () -> roma.substr(cursor, chunkSize)
  # Checks if the character is uppercase
  isCharUpperCase = (char) ->
    wanakana._isCharInRange(char, wanakana.UPPERCASE_START, wanakana.UPPERCASE_END)

  # Steps through the string pulling out chunks of characters. Each chunk will be evaluated
  # against the romaji to kana table. If there is no match, the last character in the chunk
  # is dropped and the chunk is reevaluated. If nothing matches, the character is assumed
  # to be invalid or puncuation or other and gets passed through.
  while cursor < len
    # Don't pick a chunk that is bigger than the remaining characters.
    chunkSize = Math.min(maxChunk, len-cursor)
    while chunkSize > 0
      chunk = getChunk()
      chunkLC = chunk.toLowerCase()

      # Handle super-rare edge cases with 4 char chunks (like ltsu, chya, shya)
      if chunkLC in wanakana.FOUR_CHARACTER_EDGE_CASES and (len-cursor) >= 4
        chunkSize++
        chunk = getChunk()
        chunkLC = chunk.toLowerCase()
      else
        # Handle edge case of n followed by consonant

        if chunkLC.charAt(0) is "n"
          if options.IMEMode and chunkLC.charAt(1) is "'" and chunkSize is 2
            #convert n' to "ん"
            kanaChar = "ん"
            break
          # Handle edge case of n followed by n and vowel
          if wanakana._isCharConsonant(chunkLC.charAt(1), no) and wanakana._isCharVowel(chunkLC.charAt(2))
            chunkSize = 1
            chunk = getChunk()
            chunkLC = chunk.toLowerCase()

        # Handle case of double consonants
        if chunkLC.charAt(0) isnt "n" and
        wanakana._isCharConsonant(chunkLC.charAt(0)) and
        chunk.charAt(0) == chunk.charAt(1)
          chunkSize = 1
          # Return katakana ッ if chunk is uppercase, otherwise return hiragana っ
          if wanakana._isCharInRange(chunk.charAt(0), wanakana.UPPERCASE_START, wanakana.UPPERCASE_END)
            chunkLC = chunk = "ッ"
          else
            chunkLC = chunk = "っ"

      kanaChar = wanakana.R_to_J[chunkLC]
      # DEBUG
      # console.log (cursor + "x" + chunkSize + ":" + chunk + " => " + kanaChar )
      break if kanaChar?

      # Step down the chunk size.
      # If chunkSize was 4, step down twice.
      if chunkSize == 4
        chunkSize -= 2
      else
        chunkSize--

    unless kanaChar?
      chunk = wanakana._convertPunctuation(chunk)
      # console.log("Couldn't find " + chunk + ". Passing through.")
      # Passthrough undefined values
      kanaChar = chunk

    # Handle special cases.
    if options?.useObseleteKana
      if chunkLC is "wi" then kanaChar = "ゐ"
      if chunkLC is "we" then kanaChar = "ゑ"

    if options.IMEMode and chunkLC.charAt(0) is "n"
      if roma.charAt(cursor + 1).toLowerCase() is "y" and
      wanakana._isCharVowel(roma.charAt(cursor + 2)) is false or
      cursor is (len - 1) or
      wanakana.isKana(roma.charAt(cursor + 1))
        # Don't transliterate this yet.
        kanaChar = chunk.charAt(0)

    # Use katakana if first letter in chunk is uppercase
    unless ignoreCase
      if isCharUpperCase(chunk.charAt(0))
        kanaChar = wanakana._hiraganaToKatakana(kanaChar)

    kana.push kanaChar
    cursor += chunkSize or 1

  kana.join("")

# This is the implementation of lang-cheatsheet's Korean Consonant Rules feature.
# It lives here because most of the consonant rules are invoked when romanizing.
# The consonantRules option indicates whether to follow the default behavior of
# enabling rules used in romanization (this occurs when the option is false).
# The responsibility of extracting only the information used when simply
# romanizing lies in the external facing/"public" fn.
wanakana._hangeulToRomaja = (hang, options) ->
  # options is used in external facing methods, so it's extended from the default
  # options there
  transliterate = (ch) ->
    if wanakana._isCharKorean(ch)
      initCons = wanakana.K_to_R_CONS_INITIAL[getInitial(ch)]
      vowel = wanakana.K_to_R_VOWELS[getVowel(ch)]
      # is null when there's no initial consonant
      finalCons = wanakana.K_to_R_CONS_FINAL[getFinal(ch)] ? ''
      initCons + vowel + finalCons
    else ch

  changeFmts =
    resylCurrent: (init, cons, final) ->
      rule: 'resyl'
      init: init
      final: final
      brief: "Gives #{cons}"
      detail: "#{init} ends with a consonant and is followed by a syllable starting " +
              "with a vowel, so its final consonant #{cons} is given to the next " +
              "syllable"
    resylNext: (init, cons, final) ->
      rule: 'resyl'
      init: init
      final: final
      brief: "Receives #{cons}"
      detail: "#{init} starts with a vowel and is preceded by a syllable ending " +
              "with a consonant, so it receives the final consonant #{cons}"

  len = hang.length
  hang += ' ' # ending buffer
  console.log 'hang: ' + hang
  results = hang.split('').map (h) ->
    hangeul_init: h
    romaja_init: transliterate(h)
    hangeul_final: h
    romaja_final: transliterate(h)
    changes: []
  console.log "results init: " + JSON.stringify results
  cursor = 0

  # A recursive function for parsing a chunk of Hangeul to Romaja. Transliterates
  # and applies special rule conversions. Recurses after applying a rule, since
  # multiple rules can apply to a single syllable. Takes and returns the full
  # list of results since applying a rule to a given syllable can cause every
  # single syllable to be changed.
  recurseToRomaja = (results, index, options) ->
    createVars = (results, index) ->
      [
        results[index].hangeul_final,
        results[index].romaja_final,
        hangeul_init: results[index].hangeul_init
        romaja_init: results[index].romaja_init
        hangeul_final: results[index].hangeul_final
        romaja_final: results[index].romaja_final
        changes: results[index].changes
      ]

    [current, currentR, currentUpdate] = createVars(results, index)
    [next, nextR, nextUpdate] = createVars(results, index + 1)

    console.log 'current: ' + current
    console.log 'next: ' + next
    initial = getInitial(current)
    vowel = getVowel(current)
    final = getFinal(current)
    if options.rules & wanakana.ROMAJA_RULES.RESYLLABIFICATION
      if final? and startsWithVowel(next)
        newCurrent = dropFinal(current)
        newNext = replaceInitial(next, initial)
        givenCons = getFinal(current)

        results[index] = currentUpdate
        changes = changeFmts.resylCurrent(current, givenCons, newCurrent)
        console.log changes
        results[index] = results[index].changes.concat changes

        results[index + 1] = nextUpdate
        results[index + 1].changes = results[index + 1].changes.concat changeFmts.resylNext(next, givenCons, newNext)

        console.log results
        console.log index
        recurseToRomaja(results, 0, options) #TODO: Fix this recursion

    results

  for cursor in [0...len] # stop before the ending buffer
    # always get two, since special rules only affect up to two syllables
    console.log results[cursor]
    console.log results[cursor].hangeul_final?
    if wanakana._isCharJamo(results[cursor].hangeul_final)
      results[cursor].hangeul_final = wanakana.K_to_R_JAMO[results[cursor].hangeul_final]

    else if wanakana._isCharHangeul(results[cursor].hangeul_final)
      results = recurseToRomaja(results, cursor, options)

    else
      results[cursor].hangeul_final = results[cursor].hangeul_final

  console.log "~~~"
  results[0..-2] # drop the ending buffer

wanakana._convertPunctuation = (input, options) ->
  if input is '　' then return ' '
  if input is '-' then return 'ー'
  input


###*
* Returns true if input is entirely hiragana.
###
wanakana.isHiragana = (input) ->
  chars = input.split("")
  chars.every(wanakana._isCharHiragana)

wanakana.isKatakana = (input) ->
  chars = input.split("")
  chars.every(wanakana._isCharKatakana)

wanakana.isKana = (input) ->
  chars = input.split("")
  chars.every((char) -> (wanakana.isHiragana char) or (wanakana.isKatakana char))

wanakana.isRomaji = (input) ->
  chars = input.split("")
  chars.every((char) -> (not wanakana.isHiragana char) and (not wanakana.isKatakana char))


wanakana.toHiragana = (input, options) ->
  if wanakana.isRomaji(input)
    return input = wanakana._romajiToHiragana(input, options)
  if wanakana.isKatakana(input)
    return input = wanakana._katakanaToHiragana(input, options)
  # otherwise
  input

wanakana.toKatakana = (input, options) ->
  if wanakana.isHiragana(input)
    return input = wanakana._hiraganaToKatakana(input, options)
  if wanakana.isRomaji(input)
    input = wanakana._romajiToHiragana(input, options)
    return input = wanakana._hiraganaToKatakana(input, options)
  #otherwise
  input

wanakana.toKana = (input, options) ->
  return input = wanakana._romajiToKana(input, options)

wanakana.toRomaji = (input, options) ->
  return input = wanakana._hiraganaToRomaji(input, options)

wanakana.toRomaja = (input, options) ->
  options = wanakana._extend(options, wanakana.defaultOptions)
  if options.romajaOnly
    return input = wanakana._hangeulToRomaja(input, options).map((h) -> h.romaaa_final)
                                                            .join(options['separator'])
  else if options.hangeulOnly
    return input = wanakana._hangeulToRomaja(input, options).map((h) -> h.hangeul_final)
                                                            .join(options['separator'])
  else
    return input = wanakana._hangeulToRomaja(input, options)

wanakana.R_to_J =
  a: 'あ'
  i: 'い'
  u: 'う'
  e: 'え'
  o: 'お'
  yi: 'い'
  wu: 'う'
  whu: 'う'
  xa: 'ぁ'
  xi: 'ぃ'
  xu: 'ぅ'
  xe: 'ぇ'
  xo: 'ぉ'
  xyi: 'ぃ'
  xye: 'ぇ'
  ye: 'いぇ'
  wha: 'うぁ'
  whi: 'うぃ'
  whe: 'うぇ'
  who: 'うぉ'
  wi: 'うぃ'
  we: 'うぇ'
  va: 'ゔぁ'
  vi: 'ゔぃ'
  vu: 'ゔ'
  ve: 'ゔぇ'
  vo: 'ゔぉ'
  vya: 'ゔゃ'
  vyi: 'ゔぃ'
  vyu: 'ゔゅ'
  vye: 'ゔぇ'
  vyo: 'ゔょ'
  ka: 'か'
  ki: 'き'
  ku: 'く'
  ke: 'け'
  ko: 'こ'
  lka: 'ヵ'
  lke: 'ヶ'
  xka: 'ヵ'
  xke: 'ヶ'
  kya: 'きゃ'
  kyi: 'きぃ'
  kyu: 'きゅ'
  kye: 'きぇ'
  kyo: 'きょ'
  ca: 'か'
  ci: 'き'
  cu: 'く'
  ce: 'け'
  co: 'こ'
  lca: 'ヵ'
  lce: 'ヶ'
  xca: 'ヵ'
  xce: 'ヶ'
  qya: 'くゃ'
  qyu: 'くゅ'
  qyo: 'くょ'
  qwa: 'くぁ'
  qwi: 'くぃ'
  qwu: 'くぅ'
  qwe: 'くぇ'
  qwo: 'くぉ'
  qa: 'くぁ'
  qi: 'くぃ'
  qe: 'くぇ'
  qo: 'くぉ'
  kwa: 'くぁ'
  qyi: 'くぃ'
  qye: 'くぇ'
  ga: 'が'
  gi: 'ぎ'
  gu: 'ぐ'
  ge: 'げ'
  go: 'ご'
  gya: 'ぎゃ'
  gyi: 'ぎぃ'
  gyu: 'ぎゅ'
  gye: 'ぎぇ'
  gyo: 'ぎょ'
  gwa: 'ぐぁ'
  gwi: 'ぐぃ'
  gwu: 'ぐぅ'
  gwe: 'ぐぇ'
  gwo: 'ぐぉ'
  sa: 'さ'
  si: 'し'
  shi: 'し'
  su: 'す'
  se: 'せ'
  so: 'そ'
  za: 'ざ'
  zi: 'じ'
  zu: 'ず'
  ze: 'ぜ'
  zo: 'ぞ'
  ji: 'じ'
  sya: 'しゃ'
  syi: 'しぃ'
  syu: 'しゅ'
  sye: 'しぇ'
  syo: 'しょ'
  sha: 'しゃ'
  shu: 'しゅ'
  she: 'しぇ'
  sho: 'しょ'
  shya: 'しゃ' # note 4 character code
  shyu: 'しゅ' # note 4 character code
  shye: 'しぇ' # note 4 character code
  shyo: 'しょ' # note 4 character code
  swa: 'すぁ'
  swi: 'すぃ'
  swu: 'すぅ'
  swe: 'すぇ'
  swo: 'すぉ'
  zya: 'じゃ'
  zyi: 'じぃ'
  zyu: 'じゅ'
  zye: 'じぇ'
  zyo: 'じょ'
  ja: 'じゃ'
  ju: 'じゅ'
  je: 'じぇ'
  jo: 'じょ'
  jya: 'じゃ'
  jyi: 'じぃ'
  jyu: 'じゅ'
  jye: 'じぇ'
  jyo: 'じょ'
  ta: 'た'
  ti: 'ち'
  tu: 'つ'
  te: 'て'
  to: 'と'
  chi: 'ち'
  tsu: 'つ'
  ltu: 'っ'
  xtu: 'っ'
  tya: 'ちゃ'
  tyi: 'ちぃ'
  tyu: 'ちゅ'
  tye: 'ちぇ'
  tyo: 'ちょ'
  cha: 'ちゃ'
  chu: 'ちゅ'
  che: 'ちぇ'
  cho: 'ちょ'
  cya: 'ちゃ'
  cyi: 'ちぃ'
  cyu: 'ちゅ'
  cye: 'ちぇ'
  cyo: 'ちょ'
  chya: 'ちゃ' # note 4 character code
  chyu: 'ちゅ' # note 4 character code
  chye: 'ちぇ' # note 4 character code
  chyo: 'ちょ' # note 4 character code
  tsa: 'つぁ'
  tsi: 'つぃ'
  tse: 'つぇ'
  tso: 'つぉ'
  tha: 'てゃ'
  thi: 'てぃ'
  thu: 'てゅ'
  the: 'てぇ'
  tho: 'てょ'
  twa: 'とぁ'
  twi: 'とぃ'
  twu: 'とぅ'
  twe: 'とぇ'
  two: 'とぉ'
  da: 'だ'
  di: 'ぢ'
  du: 'づ'
  de: 'で'
  do: 'ど'
  dya: 'ぢゃ'
  dyi: 'ぢぃ'
  dyu: 'ぢゅ'
  dye: 'ぢぇ'
  dyo: 'ぢょ'
  dha: 'でゃ'
  dhi: 'でぃ'
  dhu: 'でゅ'
  dhe: 'でぇ'
  dho: 'でょ'
  dwa: 'どぁ'
  dwi: 'どぃ'
  dwu: 'どぅ'
  dwe: 'どぇ'
  dwo: 'どぉ'
  na: 'な'
  ni: 'に'
  nu: 'ぬ'
  ne: 'ね'
  no: 'の'
  nya: 'にゃ'
  nyi: 'にぃ'
  nyu: 'にゅ'
  nye: 'にぇ'
  nyo: 'にょ'
  ha: 'は'
  hi: 'ひ'
  hu: 'ふ'
  he: 'へ'
  ho: 'ほ'
  fu: 'ふ'
  hya: 'ひゃ'
  hyi: 'ひぃ'
  hyu: 'ひゅ'
  hye: 'ひぇ'
  hyo: 'ひょ'
  fya: 'ふゃ'
  fyu: 'ふゅ'
  fyo: 'ふょ'
  fwa: 'ふぁ'
  fwi: 'ふぃ'
  fwu: 'ふぅ'
  fwe: 'ふぇ'
  fwo: 'ふぉ'
  fa: 'ふぁ'
  fi: 'ふぃ'
  fe: 'ふぇ'
  fo: 'ふぉ'
  fyi: 'ふぃ'
  fye: 'ふぇ'
  ba: 'ば'
  bi: 'び'
  bu: 'ぶ'
  be: 'べ'
  bo: 'ぼ'
  bya: 'びゃ'
  byi: 'びぃ'
  byu: 'びゅ'
  bye: 'びぇ'
  byo: 'びょ'
  pa: 'ぱ'
  pi: 'ぴ'
  pu: 'ぷ'
  pe: 'ぺ'
  po: 'ぽ'
  pya: 'ぴゃ'
  pyi: 'ぴぃ'
  pyu: 'ぴゅ'
  pye: 'ぴぇ'
  pyo: 'ぴょ'
  ma: 'ま'
  mi: 'み'
  mu: 'む'
  me: 'め'
  mo: 'も'
  mya: 'みゃ'
  myi: 'みぃ'
  myu: 'みゅ'
  mye: 'みぇ'
  myo: 'みょ'
  ya: 'や'
  yu: 'ゆ'
  yo: 'よ'
  xya: 'ゃ'
  xyu: 'ゅ'
  xyo: 'ょ'
  ra: 'ら'
  ri: 'り'
  ru: 'る'
  re: 'れ'
  ro: 'ろ'
  rya: 'りゃ'
  ryi: 'りぃ'
  ryu: 'りゅ'
  rye: 'りぇ'
  ryo: 'りょ'
  la: 'ら'
  li: 'り'
  lu: 'る'
  le: 'れ'
  lo: 'ろ'
  lya: 'りゃ'
  lyi: 'りぃ'
  lyu: 'りゅ'
  lye: 'りぇ'
  lyo: 'りょ'
  wa: 'わ'
  wo: 'を'
  lwe: 'ゎ'
  xwa: 'ゎ'
  n: 'ん'
  nn: 'ん'
  'n ': 'ん' # n + space
  xn: 'ん'
  ltsu: 'っ' # note 4 character code

wanakana.FOUR_CHARACTER_EDGE_CASES = ['lts', 'chy', 'shy']

wanakana.J_to_R =
  あ: 'a'
  い: 'i'
  う: 'u'
  え: 'e'
  お: 'o'
  ゔぁ: 'va'
  ゔぃ: 'vi'
  ゔ: 'vu'
  ゔぇ: 've'
  ゔぉ: 'vo'
  か: 'ka'
  き: 'ki'
  きゃ: 'kya'
  きぃ: 'kyi'
  きゅ: 'kyu'
  く: 'ku'
  け: 'ke'
  こ: 'ko'
  が: 'ga'
  ぎ: 'gi'
  ぐ: 'gu'
  げ: 'ge'
  ご: 'go'
  ぎゃ: 'gya'
  ぎぃ: 'gyi'
  ぎゅ: 'gyu'
  ぎぇ: 'gye'
  ぎょ: 'gyo'
  さ: 'sa'
  す: 'su'
  せ: 'se'
  そ: 'so'
  ざ: 'za'
  ず: 'zu'
  ぜ: 'ze'
  ぞ: 'zo'
  し: 'shi'
  しゃ: 'sha'
  しゅ: 'shu'
  しょ: 'sho'
  じ: 'ji'
  じゃ: 'ja'
  じゅ: 'ju'
  じょ: 'jo'
  た: 'ta'
  ち: 'chi'
  ちゃ: 'cha'
  ちゅ: 'chu'
  ちょ: 'cho'
  つ: 'tsu'
  て: 'te'
  と: 'to'
  だ: 'da'
  ぢ: 'di'
  づ: 'du'
  で: 'de'
  ど: 'do'
  な: 'na'
  に: 'ni'
  にゃ: 'nya'
  にゅ: 'nyu'
  にょ: 'nyo'
  ぬ: 'nu'
  ね: 'ne'
  の: 'no'
  は: 'ha'
  ひ: 'hi'
  ふ: 'fu'
  へ: 'he'
  ほ: 'ho'
  ひゃ: 'hya'
  ひゅ: 'hyu'
  ひょ: 'hyo'
  ふぁ: 'fa'
  ふぃ: 'fi'
  ふぇ: 'fe'
  ふぉ: 'fo'
  ば: 'ba'
  び: 'bi'
  ぶ: 'bu'
  べ: 'be'
  ぼ: 'bo'
  びゃ: 'bya'
  びゅ: 'byu'
  びょ: 'byo'
  ぱ: 'pa'
  ぴ: 'pi'
  ぷ: 'pu'
  ぺ: 'pe'
  ぽ: 'po'
  ぴゃ: 'pya'
  ぴゅ: 'pyu'
  ぴょ: 'pyo'
  ま: 'ma'
  み: 'mi'
  む: 'mu'
  め: 'me'
  も: 'mo'
  みゃ: 'mya'
  みゅ: 'myu'
  みょ: 'myo'
  や: 'ya'
  ゆ: 'yu'
  よ: 'yo'
  ら: 'ra'
  り: 'ri'
  る: 'ru'
  れ: 're'
  ろ: 'ro'
  りゃ: 'rya'
  りゅ: 'ryu'
  りょ: 'ryo'
  わ: 'wa'
  を: 'wo'
  ん: 'n'
# Archaic characters
  ゐ: 'wi'
  ゑ: 'we'
# Uncommon character combos
  きぇ: 'kye'
  きょ: 'kyo'
  じぃ: 'jyi'
  じぇ: 'jye'
  ちぃ: 'cyi'
  ちぇ: 'che'
  ひぃ: 'hyi'
  ひぇ: 'hye'
  びぃ: 'byi'
  びぇ: 'bye'
  ぴぃ: 'pyi'
  ぴぇ: 'pye'
  みぇ: 'mye'
  みぃ: 'myi'
  りぃ: 'ryi'
  りぇ: 'rye'
  にぃ: 'nyi'
  にぇ: 'nye'
  しぃ: 'syi'
  しぇ: 'she'
  いぇ: 'ye'
  うぁ: 'wha'
  うぉ: 'who'
  うぃ: 'wi'
  うぇ: 'we'
  ゔゃ: 'vya'
  ゔゅ: 'vyu'
  ゔょ: 'vyo'
  すぁ: 'swa'
  すぃ: 'swi'
  すぅ: 'swu'
  すぇ: 'swe'
  すぉ: 'swo'
  くゃ: 'qya'
  くゅ: 'qyu'
  くょ: 'qyo'
  くぁ: 'qwa'
  くぃ: 'qwi'
  くぅ: 'qwu'
  くぇ: 'qwe'
  くぉ: 'qwo'
  ぐぁ: 'gwa'
  ぐぃ: 'gwi'
  ぐぅ: 'gwu'
  ぐぇ: 'gwe'
  ぐぉ: 'gwo'
  つぁ: 'tsa'
  つぃ: 'tsi'
  つぇ: 'tse'
  つぉ: 'tso'
  てゃ: 'tha'
  てぃ: 'thi'
  てゅ: 'thu'
  てぇ: 'the'
  てょ: 'tho'
  とぁ: 'twa'
  とぃ: 'twi'
  とぅ: 'twu'
  とぇ: 'twe'
  とぉ: 'two'
  ぢゃ: 'dya'
  ぢぃ: 'dyi'
  ぢゅ: 'dyu'
  ぢぇ: 'dye'
  ぢょ: 'dyo'
  でゃ: 'dha'
  でぃ: 'dhi'
  でゅ: 'dhu'
  でぇ: 'dhe'
  でょ: 'dho'
  どぁ: 'dwa'
  どぃ: 'dwi'
  どぅ: 'dwu'
  どぇ: 'dwe'
  どぉ: 'dwo'
  ふぅ: 'fwu'
  ふゃ: 'fya'
  ふゅ: 'fyu'
  ふょ: 'fyo'
#  Small Characters (normally not transliterated alone)
  ぁ: 'a'
  ぃ: 'i'
  ぇ: 'e'
  ぅ: 'u'
  ぉ: 'o'
  ゃ: 'ya'
  ゅ: 'yu'
  ょ: 'yo'
  っ: ''
  ゕ: 'ka'
  ゖ: 'ka'
  ゎ: 'wa'
# Punctuation
  '　': ' '
# Ambiguous consonant vowel pairs
  んあ: 'n\'a'
  んい: 'n\'i'
  んう: 'n\'u'
  んえ: 'n\'e'
  んお: 'n\'o'
  んや: 'n\'ya'
  んゆ: 'n\'yu'
  んよ: 'n\'yo'

wanakana.K_to_R_CONS_INITIAL =
  ㄱ: 'g'
  ㄲ: 'kk'
  ㄴ: 'n'
  ㄷ: 'd'
  ㄸ: 'tt'
  ㄹ: 'r'
  ㅁ: 'm'
  ㅂ: 'b'
  ㅃ: 'pp'
  ㅅ: 's'
  ㅆ: 'ss'
  ㅇ: ''
  ㅈ: 'j'
  ㅉ: 'jj'
  ㅊ: 'ch'
  ㅋ: 'k'
  ㅌ: 't'
  ㅍ: 'p'
  ㅎ: 'h'
  # Double consonants, only used as finals
  ㄳ: ''
  ㄵ: ''
  ㄶ: ''
  ㄺ: ''
  ㄻ: ''
  ㄼ: ''
  ㄽ: ''
  ㄾ: ''
  ㄿ: ''
  ㅀ: ''
  ㅄ: ''

wanakana.K_to_R_JAMO = wanakana._oextend wanakana.K_to_R_CONS_INITIAL,
  ㅇ: 'ng'
  ㄳ: 'gs'
  ㄵ: 'nj'
  ㄶ: 'nh'
  ㄺ: 'rg'
  ㄻ: 'rm'
  ㄼ: 'rb'
  ㄽ: 'rs'
  ㄾ: 'rt'
  ㄿ: 'rp'
  ㅀ: 'rh'
  ㅄ: 'bs'

wanakana.K_to_R_CONS_FINAL = wanakana._oextend wanakana.K_to_R_JAMO,
  ㄱ: 'k'
  ㄷ: 't'
  ㅂ: 'p'
  ㄹ: 'l'
  ㄳ: 'k'
  ㄵ: 'n'
  ㄶ: 'n'
  ㄺ: 'l'
  ㄻ: 'm'
  ㄼ: 'l'
  ㄽ: 'l'
  ㄾ: 'l'
  ㄿ: 'p'
  ㅀ: 'l'
  ㅄ: 'p'

wanakana.K_to_R_VOWELS =
  ㅏ: 'a'
  ㅐ: 'ae'
  ㅑ: 'ya'
  ㅒ: 'yae'
  ㅓ: 'eo'
  ㅔ: 'e'
  ㅕ: 'yeo'
  ㅖ: 'ye'
  ㅗ: 'o'
  ㅘ: 'wa'
  ㅙ: 'wae'
  ㅚ: 'oe'
  ㅛ: 'yo'
  ㅜ: 'u'
  ㅝ: 'wo'
  ㅞ: 'we'
  ㅟ: 'wi'
  ㅠ: 'yu'
  ㅡ: 'eu'
  ㅢ: 'ui'
  ㅣ: 'i'

wanakana.ROMAJA_RULES =
  RESYLLABIFICATION: 0b1

module.exports = wanakana
