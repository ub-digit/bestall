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
    if (this.get('session.isAuthenticated')) {
      return Ember.RSVP.hash({
        //@FIXME: this.get('store')?
        biblio: this.store.findRecord('biblio', params.id, {adapterOptions: {items_on_subscriptions: "true"}}),
        user: this.store.queryRecord('user', {biblio: params.id})
      });
    } else {
      return Ember.RSVP.hash({
        biblio: this.store.find('biblio', params.id)
      });
    }

  },

  setupController(controller, model) {
    controller.set('model', model);
  },
 });
