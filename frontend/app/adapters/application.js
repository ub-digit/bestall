import DS from 'ember-data';
import Ember from 'ember';

export default DS.RESTAdapter.extend({

  host: 'http://localhost:3000/api/',


  handleResponse(status) {
    if (404 === status) {
      return {status: "404"};
    }
    return this._super(...arguments);
  }
});