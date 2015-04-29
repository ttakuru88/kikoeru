module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    clean:
      all: ['dist']
    watch:
      coffee:
        tasks: ['coffee']
        files: ['src/*.coffee']
      html:
        tasks: ['copy']
        files: ['src/index.html', 'src/timer.js']
    coffee:
      main:
        files:
          'dist/application.js': 'src/application.coffee'
    copy:
      main:
        files:
          'dist/index.html': 'src/index.html'
          'dist/timer.js': 'src/timer.js'
          'dist/jquery.js': 'bower_components/jquery/dist/jquery.min.js'

  grunt.registerTask 'default', ['clean', 'coffee', 'copy']

  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-watch')
