import Ember from 'ember';

export default Ember.Route.extend({
  session: Ember.inject.service(),

  queryParams: {
    location: {
      replace: true
    },
    type: {
      replace: true
    }
  },

  model() {
    let id = this.modelFor('request').id;
    return Ember.RSVP.hash({
      biblio: this.store.findRecord('biblio', id, {adapterOptions: {items_on_subscriptions: "true"}}),
      user: this.store.queryRecord('user', {biblio: id})
    }).then((result) => {
        return Ember.RSVP.hash({
          locations: this.get('store').findAll('location'),
          loantypes: this.get('store').findAll('loanType'),
          biblio: Ember.RSVP.resolve(result.biblio),
          user: Ember.RSVP.resolve(result.user),
          reserve: this.get('store').createRecord('reserve', {
            biblio: result.biblio,
            user: result.user
          })
        });
    });
  },

  setupController(controller, model) {
    controller.set('model', model);
  },

  actions: {

    goBack() {
      window.history.back();
    },

    submitOrder() {
      this.controllerFor('request.order.summary').set('btnSubmitOrderDisabled', true);
      this.controller.get('model.reserve').save().then(() => {
        this.transitionTo('request.order.confirmation');
      }, (error) => {
        this.get('controller').set('errors', error.errors);
        this.transitionTo('request.order.confirmation');
      });
    }
  },

  resetController(controller, isExiting) {
    if (isExiting) {
      let reserve = controller.get('model.reserve');
      if (reserve.get('isNew')) {
        reserve.destroyRecord();
      }
    }
  }

});
