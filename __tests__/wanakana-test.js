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
let resylInit      = ['한글은', '책을 펴세요', '알았어요', '질문이 있어요',
                      '읽어 보세요', '잘 들으세요', '맞았어요', '앉으세요',
                      '천민에요', '책이 이 층에 없어요', '영어를 쓰지 마세요',
                      '백화점에 갔어요', '읏을 받았어요']
let resylRes       = ['한그른', '채글 펴세요', '아라써요', '질무니 이써요',
                      '일거 보세요', '잘 드르세요', '마자써요', '안즈세요',
                      '천미네요', '채기 이 층에 업서요', '영어를 쓰지 마세요',
                      '백화저메 가써요', '으슬 바다써요']
// groups of the syllables with consonant finals used above
let words          = ['각팦갻', '냰깪넪', '뎓넍롥', '뢂롈뢼', '룙뢟뤓', '뭼룶븂',
                      '슷뷥잉', '잦씠캌', '탙찿핳']
let romanWords     = ['gak-pap-kkyak', 'nyaen-kkaeng-nen', 'dyeon-neol-lok',
                      'rwam-nyel-loel']
//TODO note how ㅁ is nasal, so ㅁ + ㄹ makes the ㄹ become ㄴ

let sylIndicies = Array(syllables.length).fill().map((_, i) => i)
let resylIndicies = Array(resylInit.length).fill().map((_, i) => i)
let wordsIndicies = Array(words.length).fill().map((_, i) => i)

describe('resyllabification', () => {
  for(let i of resylIndicies) {
    fit(`should resyllabify ${resylInit[i]} to ${resylRes[i]}`, () => {
      expect(toRomaja(resylInit[i], {rules: ROMAJA_RULES.RESYLLABIFICATION,
                                     romajaOnly: true})).toEqual(toRomaja(resylRes[i], {romajaOnly: true}))
    })
  }
})

describe('toRomaja', () => {
  for(let i of sylIndicies) {
    it(`should romanize the syllable ${syllables[i]} to ${romans[i]}`, () => {
      expect(toRomaja(syllables[i], {romajaOnly: true})).toEqual(romans[i])
    })
  }

  for(let i of wordsIndicies) {
    if(romanWords[i]) {
      xit(`should romanize the word ${words[i]} to ${romanWords[i]}`, () => {
        expect(toRomaja(words[i], {separator: '-'})).toEqual(romanWords[i])
      })
    }
  }
})
