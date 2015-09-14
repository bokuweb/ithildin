gulp     = require 'gulp'
coffee   = require 'gulp-coffee'
plumber  = require 'gulp-plumber'
stylus   = require 'gulp-stylus'

gulp.task 'build:renderer', ->
  gulp.src './src/renderer/src/*.coffee'
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest './src/renderer/js/'

gulp.task 'build:browser', ->
  gulp.src './src/browser/src/*.coffee'
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest './src/browser/js/'

gulp.task 'build:test', ->
  gulp.src './test/src/*.coffee'
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest './test'

gulp.task 'build:stylus', ->
  gulp.src './src/renderer/styl/*.styl'
    .pipe plumber()
    .pipe stylus
      compress: true
    .pipe gulp.dest './src/renderer/stylesheets'

gulp.task 'build:coffee', ['build:renderer', 'build:browser', 'build:test']

gulp.task 'build', ['build:coffee', 'build:stylus']

gulp.task 'watch', ->
  gulp.watch ['./src/renderer/styl/*.styl'], ['build:stylus']
  gulp.watch ['./src/*/src/*.coffee'], ['build:coffee']
  gulp.watch ['./test/src/*.coffee'], ['build:test']
