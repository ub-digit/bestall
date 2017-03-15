import Ember from 'ember';

export default Ember.Controller.extend({
  login: Ember.inject.controller('request.login')
});
