import ActiveModelAdapter from 'active-model-adapter';
import Ember from 'ember';
import ENV from '../config/environment';

export default ActiveModelAdapter.extend({
  session: Ember.inject.service(),
  namespace: 'api',
  host: ENV.APP.serviceURL,

  headers: Ember.computed(function() {
    return {
      'Authorization': 'Token ' + this.get('session.data.authenticated.token')
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
