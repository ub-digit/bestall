import DS from 'ember-data';
import ActiveModelAdapter from 'active-model-adapter';
import Ember from 'ember';

export default ActiveModelAdapter.extend({
  host: '/api',
  handleResponse(status) {
    if (404 === status) {
      return {status: "404"};
    }
    return this._super(...arguments);
  }
});
