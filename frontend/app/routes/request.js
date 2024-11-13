import Ember from 'ember';

export default Ember.Route.extend({
  session: Ember.inject.service(),

  beforeModel(transition) {
    let biblioId = transition.params.request.id;

    if (biblioId === "error") {
      return new Ember.RSVP.Promise((resolve, reject) => {
        reject({errors: {errors: [{"code": 'NO_ID', "detail": "loreum"}]}});
      });
    }
    if (!this.get('session.isAuthenticated')) {
      this.replaceWith('request.login');
    }
    else {
      this.replaceWith('request.order.items');
    }
  },

  model(params) {
    return params.id;
  },

  setupController(controller, model) {
    controller.set('model', model);
  },
 });
