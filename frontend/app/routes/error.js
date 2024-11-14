import Ember from 'ember';

export default Ember.Route.extend({
  setupController(controller, error) {
    console.log("error", error);
  }
});
