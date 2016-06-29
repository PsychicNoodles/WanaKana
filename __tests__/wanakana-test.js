jest.unmock('../src/coffee/wanakana')
jest.unmock('../src/coffee/utils')

import {toRomaja, ROMAJA_RULES} from '../src/coffee/wanakana'

// lone syllables, so only with Syllable-final Closure, which affects ends of words
let syllables      = ['각', '깪', '갻', '냰', '넍', '넪', '뎓', '롈', '롥', '뢂', '뢟',
                      '뢼', '룙', '룶', '뤓', '뭼', '뷥', '븂', '슷', '씠', '잉', '잦',
                      '찿', '캌', '탙', '팦', '핳']
let romans         = ['gak', 'kkaekk', 'gyak', 'nyaen', 'neon', 'nen', 'dyeot',
                      'ryel', 'rol', 'rwam', 'rwael', 'roel', 'ryol', 'rup', 'rwol',
                      'mwem', 'bwip', 'byup', 'seut', 'ssuit', 'ing', 'jat', 'chat',
                      'kak', 'tat', 'pap', 'hat']
// consonant pronunciation tests sourced largely from the Integrated Korean
// Beginning Level 1 textbook, except when an important case was not provided

// groups of the syllables with consonant finals used above
let words          = ['각팦갻', '냰깪넪', '뎓넍롥', '뢂롈뢼', '룙뢟뤓', '뭼룶븂',
                      '슷뷥잉', '잦씠캌', '탙찿핳']
let romanWords     = ['gak-pap-kkyak', 'nyaen-kkaeng-nen', 'dyeon-neol-lok',
                      'rwam-nyel-loel']
//TODO note how ㅁ is nasal, so ㅁ + ㄹ makes the ㄹ become ㄴ

let wordsIndicies = Array(words.length).fill().map((_, i) => i)

describe('toRomaja', () => {
  for(let i of sylIndicies) {
    fit(`should romanize the syllable ${syllables[i]} to ${romans[i]}`, () => {
      expect(toRomaja(syllables[i])).toEqual(romans[i])
    })
  }

  for(let i of wordsIndicies) {
    if(romanWords[i]) {
      it(`should romanize the word ${words[i]} to ${romanWords[i]}`, () => {
        expect(toRomaja(words[i])).toEqual(romanWords[i])
      })
    }
  }
})
