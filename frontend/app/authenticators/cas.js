import Ember from 'ember';
import Base from 'ember-simple-auth/authenticators/base';
import ENV from 'frontend/config/environment';

export default Base.extend({
  store: Ember.inject.service(),

  authenticate: function(credentials) {
    var authCredentials = {};
    var that = this;
    if(credentials.cas_ticket && credentials.cas_service) {
      authCredentials = credentials;
    } else {
      authCredentials = {
        username: credentials.username,
        password: credentials.password
      };
    }
    return new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        type: 'POST',
        url: ENV.APP.authenticationBaseURL,
        data: JSON.stringify(authCredentials),
        contentType: 'application/json'
      }).then(function(response) {
        var token = response.access_token;
        that.get('store').createRecord('token', {id: 1, token: token});
        resolve({
          authenticated: true,
          token: token
        });
      }, function(xhr) {
        reject(xhr.responseJSON);
      });
    });
  },
  invalidate: function() {
    // TODO: perhaps invalidate, or not implement, or reason to leave as is?
    return Ember.RSVP.resolve();
  }
});
