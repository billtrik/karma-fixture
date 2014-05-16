// Karma configuration
// Generated on Fri May 16 2014 13:49:58 GMT+0300 (EEST)

module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['mocha', 'chai'],
    files: [
      'src/fixture.coffee',
      {
        pattern  : 'spec/**/*.coffee',
        included : true,
        served   : true,
        watched  : true
      }
    ],
    preprocessors: {
      '**/*.coffee' : ['coffee']
    },
    coffeePreprocessor: {
      options: {
        bare: false
      },
    },
    reporters: ['mocha'],
    logLevel: config.LOG_INFO,
    browsers: ['PhantomJS'],
    autoWatch: false,
    singleRun: true
  });
};
