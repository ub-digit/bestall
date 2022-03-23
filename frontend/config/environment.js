/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    modulePrefix: 'frontend',
    environment: environment,
    rootURL: '/',
    locationType: 'auto',

    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
      authenticationBaseURL: '/api/session',
      serviceURL: ''
    }
  };


  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    ENV.APP.LOG_TRANSITIONS = true;
    ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }
  else {
    ENV.APP.serviceURL = process.env.BACKEND_SERVICE_PROTOCOL + '://' + process.env.BACKEND_SERVICE_HOSTNAME;
    if (process.env.BACKEND_SERVICE_PORT) {
      ENV.APP.serviceURL = ENV.APP.serviceURL + ':' + process.env.BACKEND_SERVICE_PORT;
    }
    ENV.APP.authenticationBaseURL = ENV.APP.serviceURL + '/api/session';
  }

  ENV.i18n = {
    defaultLocale: 'sv'
  }
  ENV.error_codes = {
    NO_ID: "NO_ID"
  }

   ENV.contentSecurityPolicy = {
    'default-src': "'none'",
    'font-src': "'self'",
    'img-src': "'self'",
    'style-src': "'self'",
    'style-src': "'self' 'unsafe-inline'",
    'report-uri': "/"
  };

  return ENV;
};
