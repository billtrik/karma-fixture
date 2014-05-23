module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    bump: {
      options: {
        pushTo: 'origin',
      }
    },
  });

  grunt.loadNpmTasks('grunt-bump');
};
