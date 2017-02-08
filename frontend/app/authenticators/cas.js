import Ember from 'ember';
import Base from 'ember-simple-auth/authenticators/base';
import ENV from 'frontend/config/environment';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

export default Base.extend({
  restore: function(properties) {
    return new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        type: 'GET',
        url: ENV.APP.authenticationBaseURL+'/'+properties.token
      }).then(function() {
        resolve(properties);
      }, function() {
        reject();
      });
    });
  },
  authenticate: function(credentials) {

    var authCredentials = {};
    if(credentials.cas_ticket && credentials.cas_service) {
      authCredentials = credentials;
    }
    // else {
    //   authCredentials = {
    //     username: credentials.identification,
    //     password: credentials.password
    //   };
    // }
    return new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        type: 'POST',
        url: ENV.APP.authenticationBaseURL,
        data: JSON.stringify(authCredentials),
        contentType: 'application/json'
      }).then(function(response) {
        var token = response.access_token;
        Ember.run(function() {
          resolve({
            authenticated: true,
            token: token,
            username: response.user.username,
            name: response.user.name
          });
        });
      }, function(xhr) {
        Ember.run(function() {
          reject(xhr.responseJSON.error);
        });
      });
    });
  },
  invalidate: function() {
    return new Ember.RSVP.Promise(function(resolve) {
      resolve();
    });
  }
});


AuthenticatedRouteMixin.reopen({
  beforeModel: function(transition) {
    var session = this.get('session');
    var token = null;
    if(session) {
      token = session.get('data.authenticated.token');
    }
    Ember.$.ajax({
      type: 'GET',
      url: ENV.APP.authenticationBaseURL+'/'+token
    }).then(null, function() {
      session.invalidate();
    });
    return this._super(transition);
  }
});
