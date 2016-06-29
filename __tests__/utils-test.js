jest.unmock('../src/coffee/utils')

import {isJamoVowel, isJamoConsonant, getInitial, startsWithVowel, replaceInitial,
        getVowel, hasFinal, getFinal, dropFinal}
        from '../src/coffee/utils'

let vowels       = ['ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ',
                    'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ']
let consonants   = ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ',
                    'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']
let dubCons      = ['ㄲ', 'ㄳ', 'ㄵ', 'ㄶ', 'ㄸ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ',
                    'ㅀ', 'ㅃ', 'ㅄ']

// every possible final consonant with either corresponding initial consonant or
// non-doubled version
// also every vowel, with duplicates on the last 6 syllables with, just because
// there are fewer vowels than possible final consonants/double consonants
let withFinals   = ['각', '깪', '갻', '냰', '넍', '넪', '뎓', '롈', '롥', '뢂', '뢟',
                    '뢼', '룙', '룶', '뤓', '뭼', '뷥', '븂', '슷', '씠', '잉', '잦',
                    '찿', '캌', '탙', '팦', '핳']
// these indeed may have duplicates, but they're parallel to withFinals
// the same syllables as withFinals, but without final consonants
let woFinals     = ['가', '깨', '갸', '냬', '너', '네', '뎌', '례', '로', '롸', '뢔',
                    '뢰', '료', '루', '뤄', '뭬', '뷔', '뷰', '스', '씌', '이', '자',
                    '차', '카', '타', '파', '하']
// the final consonants from withFinals
let consFinals   = ['ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ',
                    'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ',
                    'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']
// the initial consonants from withFinals
let consInitials = ['ㄱ', 'ㄲ', 'ㄱ', 'ㄴ', 'ㄴ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㄹ', 'ㄹ', 'ㄹ',
                    'ㄹ', 'ㄹ', 'ㄹ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅂ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ',
                    'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']
// the vowels from withFinals
let onlyVowels   = ['ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ',
                    'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ', 'ㅏ',
                    'ㅏ', 'ㅏ', 'ㅏ', 'ㅏ', 'ㅏ']
// withFinals initials replaced by consInitials in reverse order
let rplInitials  = ['학', '팪', '탻', '컌', '첝', '젢', '엳', '쏄', '솕', '봚', '봴',
                    '묈', '룙', '룶', '뤓', '뤰', '륍', '륪', '릇', '릤', '딩', '낮',
                    '낯', '낰', '같', '깦', '갛']

let initialVowel = [false, false, false, false, false, false, false, false, false,
                    false, false, false, false, false, false, false, false, false,
                    false, false, true, false, false, false, false, false, false]

let withFinalsIndicies = Array(withFinals.length).fill().map((_, i) => i)

describe('isJamoVowel', () => {
  for(let v of vowels) {
    it('should identify the vowel ' + v, () => {
      expect(isJamoVowel(v)).toBeTruthy()
    })
  }

  for(let c of consonants) {
    it('should not identify the consonant ' + c, () => {
      expect(isJamoVowel(c)).toBeFalsy()
    })
  }

  for(let c of dubCons) {
    it('should not identify the double consonant ' + c, () => {
      expect(isJamoVowel(c)).toBeFalsy()
    })
  }
})

describe('isJamoConsonant', () => {
  for(let v of vowels) {
    it('should not identify the vowel ' + v, () => {
      expect(isJamoConsonant(v)).toBeFalsy()
    })
  }

  for(let c of consonants) {
    it('should identify the consonant ' + c, () => {
      expect(isJamoConsonant(c)).toBeTruthy()
    })
  }

  for(let c of dubCons) {
    it('should identify the double consonant ' + c, () => {
      expect(isJamoConsonant(c)).toBeTruthy()
    })
  }
})

describe('getInitial', () => {
  for(let i of withFinalsIndicies) {
    it(`should return the consonant initial ${consInitials[i]} of ${withFinals[i]}`, () => {
      expect(getInitial(withFinals[i])).toEqual(consInitials[i])
    })
  }
})

describe('startsWithVowel', () => {
  for(let i of withFinalsIndicies) {
    it(`should return ${initialVowel[i]}`, () => {
      expect(startsWithVowel(withFinals[i])).toEqual(initialVowel[i])
    })
  }
})

describe('replaceInitial', () => {
  for(let i of withFinalsIndicies) {
    let rplInitial = rplInitials[rplInitials.length - i - 1] //reverse order
    xit(`should replace the consonant initial ${consInitials[i]} of ${withFinals[i]} ` +
       `with ${rplInitial}, resulting in ${rplInitials[i]}`, () => {
      expect(replaceInitial(withFinals[i], rplInitial)).toEqual(rplInitials[i])
    })
  }
})

describe('getVowel', () => {
  for(let i of withFinalsIndicies) {
    it(`should return the vowel ${onlyVowels[i]} of ${withFinals[i]} (index ${i})`, () => {
      expect(getVowel(withFinals[i])).toEqual(onlyVowels[i])
    })
  }
})

describe('hasFinal', () => {
  for(let e of withFinals) {
    it('should identify the syllable with a consonant Final ' + e, () => {
      expect(hasFinal(e)).toBeTruthy()
    })
  }

  for(let e of woFinals) {
    it('should not identify the syllable without a consonant Final ' + e, () => {
      expect(hasFinal(e)).toBeFalsy()
    })
  }
})

describe('getFinal', () => {
  for(let i of withFinalsIndicies) {
    it(`should return the consonant final ${consFinals[i]} of ${withFinals[i]}`, () => {
      expect(getFinal(withFinals[i])).toEqual(consFinals[i])
    })
  }
})

describe('dropFinal', () => {
  for(let i of withFinalsIndicies) {
    it(`should remove the consonant Final ${consFinals[i]} of ${withFinals[i]}, ` +
       `resulting in ${woFinals[i]}`, () => {
      expect(dropFinal(withFinals[i])).toEqual(woFinals[i])
    })
  }
})
