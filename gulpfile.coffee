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
    
gulp.task 'build:coffee', ['build:renderer', 'build:browser']
gulp.task 'build:stylus', ->
  gulp.src 'public/styl/*.styl'
    .pipe plumber()
    .pipe stylus
      compress: true
    .pipe gulp.dest 'public/css'

gulp.task 'watch', ->
  gulp.watch ['public/styl/*.styl'], ['build:stylus']
  gulp.watch ['./src/*/src/*.coffee'], ['build:coffee']

