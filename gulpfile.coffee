gulp     = require 'gulp'
coffee   = require 'gulp-coffee'
plumber  = require 'gulp-plumber'
stylus   = require 'gulp-stylus'

gulp.task 'build:coffee', ->
  gulp.src ['app/src/*.coffee']
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest 'app/js'

gulp.task 'build:stylus', ->
  gulp.src 'public/styl/*.styl'
    .pipe plumber()
    .pipe stylus
      compress: true
    .pipe gulp.dest 'public/css'

gulp.task 'watch', ->
  gulp.watch ['public/styl/*.styl'], ['build:stylus']
  gulp.watch ['app/src/*.coffee'], ['build:coffee']

