import DS from 'ember-data';
import ActiveModelAdapter from 'active-model-adapter';
import Ember from 'ember';

export default ActiveModelAdapter.extend({
  session: Ember.inject.service(),
  namespace: '/api',

  headers: Ember.computed('session.data.authenticated.token', function() {
    return {
      'Authorization': 'Token ' + this.get('session.data.authenticated.token')
    }
  }),

  handleResponse(status, header, payload) {
    if (404 === status) {
      return {status: "404",
              payload:payload};
    }
    return this._super(...arguments);
  }
});
