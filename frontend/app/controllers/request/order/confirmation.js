import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order')

});
