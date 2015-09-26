'use strict'

taskName = 'Coffeelint' # used with humans
safeTaskName = 'coffeelint' # used with machines

coffeelint = require 'gulp-coffeelint'

{getConfig, gulp, API: {notify, merge, handleError, typeCheck, debug}} = require 'pavios'
debug = debug 'task:' + taskName

config = getConfig safeTaskName

defaultOpts =
  linterOpts: {}

config.linterOpts = Object.assign {}, defaultOpts.linterOpts, config.linterOpts

# debug 'Merged config: ', config

configType = '{
  files: [String],
  linterOpts: Maybe Object
}'

result = typeCheck.raw configType, config
debug 'Type check ' + (if result then 'passed' else 'failed')

unless result
  typeCheck.typeCheckErr taskName

gulp.task safeTaskName, (cb) ->
  unless result
    debug 'Exiting task early because config is invalid'
    return cb()

  streams = []

  for file in config.files
    debug "Creating stream for file(s) #{file}..."
    streams.push(
      gulp.src file
      .pipe do handleError taskName
      .pipe coffeelint config.linterOpts
      .pipe coffeelint.reporter()
      .on 'end', -> notify.taskFinished taskName
    )

  merge streams

module.exports.order = 1
module.exports.sources = config.files
