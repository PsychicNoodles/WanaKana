var babel = require('babel-core')
var jestPreset = require('babel-preset-jest')
var coffee = require('coffee-script');

module.exports = {
  process: function(src, filename) {
    if (filename.match(/\.coffee|\.cjsx/)) {
      src = coffee.compile(src, {bare: true});
    }
    // babel-jest tests if the extension is on the list of "compilable" extensions,
    // but when chaining with Coffeescript it'll be able to compile .coffee files
    src = babel.transform(src, {
      auxiliaryCommentBefore: ' istanbul ignore next ',
      filename,
      presets: [jestPreset],
      retainLines: true,
    }).code;
    return src;
  }
};
