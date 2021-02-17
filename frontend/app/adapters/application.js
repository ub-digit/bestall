import ActiveModelAdapter from 'active-model-adapter';
import Ember from 'ember';
import ENV from '../config/environment';

export default ActiveModelAdapter.extend({
  session: Ember.inject.service(),
  store: Ember.inject.service(),
  namespace: 'api',
  host: ENV.APP.serviceURL,

  headers: Ember.computed(function() {
    var that = this;

    let token = that.get('store').peekRecord('token', 1);
    let token_string;
    if(token) {
      token_string = token.get('token');
    }
    return {
//      'Authorization': 'Token ' + this.get('session.data.authenticated.token')
      'Authorization': 'Token ' + token_string
    };
  }).volatile(),

  handleResponse(status, header, payload) {
    if (404 === status) {
      return {
        status: "404",
        errors:payload.errors
      };
    }

     if (403 === status) {
      return {
        status: "403",
        errors:payload.errors
      };
    }
    return this._super(...arguments);
  }
});
