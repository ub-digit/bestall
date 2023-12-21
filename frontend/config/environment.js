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
    },
    torii: {
      sessionServiceName: 'session',
      providers: {
        'gub-oauth2': {
          apiKey: process.env.GUB_OAUTH2_CLIENT_ID,
          scope: 'user'
        }
      }
    }
  };

  let frontendBaseUrl = null;
  let serviceBaseUrl = null;

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    ENV.APP.LOG_TRANSITIONS = true;
    ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
    serviceBaseUrl = `http://localhost:${process.env.BACKEND_SERVICE_PORT}`;
    frontendBaseUrl = `http://localhost:${process.env.FRONTEND_PORT}`;
  }
  else if (environment === 'test') {
    // Testem prefers this...
    ENV.locationType = 'none';
    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;
    ENV.APP.rootElement = '#ember-testing';
  }
  else {
    serviceBaseUrl = `https://${process.env.BACKEND_SERVICE_HOSTNAME}`;
    frontendBaseUrl = `https://${ process.env.FRONTEND_HOSTNAME}`;
  }

  if (environment !== 'test') {
    // Don't need to append 'api' since namespace: 'api' in adapter
    ENV.APP.serviceURL = serviceBaseUrl;
    // Need to append it here though since simple auth don't go through adpater
    ENV.APP.authenticationBaseURL = `${ENV.APP.serviceURL}/api/session`;
    ENV.torii.providers['gub-oauth2'].tokenExchangeUri = ENV.APP.authenticationBaseURL;
    ENV.torii.providers['gub-oauth2'].redirectUri = `${frontendBaseUrl}/torii/redirect.html`;
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
