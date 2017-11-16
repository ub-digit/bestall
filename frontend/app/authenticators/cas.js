import Ember from 'ember';
import Base from 'ember-simple-auth/authenticators/base';
import ENV from 'frontend/config/environment';
//import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

export default Base.extend({
  store: Ember.inject.service(),

  authenticate: function(credentials) {
    var authCredentials = {};
    var that = this;
    if(credentials.cas_ticket && credentials.cas_service) {
      authCredentials = credentials;
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


//@FIXME: This seems unused. Remove? Fix?
/*
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
*/
