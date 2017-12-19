import ActiveModelAdapter from 'active-model-adapter';
import Ember from 'ember';

export default ActiveModelAdapter.extend({
  session: Ember.inject.service(),
  store: Ember.inject.service(),
  namespace: '/api',

  headers: Ember.computed(function() {
    console.log("qwe4r56");
    var that = this;

    let token = that.get('store').peekRecord('token', 1);
    console.log("1", token);
    let token_string;
    console.log("2", token_string);
    if(token) {
      token_string = token.get('token');
      console.log("3", token_string);
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
