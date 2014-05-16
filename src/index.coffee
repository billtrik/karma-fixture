path = require('path')

adapter_path = path.join(__dirname, 'adapter.js')
framework_path = path.join(__dirname, 'fixture.js')

pattern = (file)->
  pattern  : file
  included : true
  served   : true
  watched  : false

framework = (files)->
  files.unshift pattern(adapter_path)
  files.unshift pattern(framework_path)
  return


framework.$inject = ['config.files']
module.exports = {'framework:fixture': ['factory', framework]}
