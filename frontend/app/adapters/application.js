import DS from 'ember-data';
import Ember from 'ember';

export default DS.RESTAdapter.extend({
  //namespace: 'api/v1',
  host: 'http://localhost:3000/api',

  pathForType: function(type) {
  	if (type === "config") {
    	return type;
    }
  },

  handleResponse(status) {
    if (404 === status) {
      return {status: "404"};
    }
    return this._super(...arguments);
  }
});