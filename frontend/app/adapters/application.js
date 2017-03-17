import ActiveModelAdapter from 'active-model-adapter';
import Ember from 'ember';

export default ActiveModelAdapter.extend({
  session: Ember.inject.service(),
  namespace: '/api',

  headers: Ember.computed('session.data.authenticated.token', function() {
    return {
      'Authorization': 'Token ' + this.get('session.data.authenticated.token')
    };
  }),

  handleResponse(status, header, payload) {
    if (404 === status) {
      return {status: "404",
              errors:payload.errors};
    }

     if (403 === status) {
      return {status: "403",
               errors:payload.errors};
    }
    return this._super(...arguments);
  }
});
