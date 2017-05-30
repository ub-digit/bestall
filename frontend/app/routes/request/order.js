import Ember from 'ember';

export default Ember.Route.extend({

  queryParams: {
    location: {
      replace: true
    },
    type: {
      replace: true
    }
  },

  model() {
    let biblio = this.modelFor('request').biblio;
    let user = this.modelFor('request').user;

    return Ember.RSVP.hash({
      locations: this.get('store').findAll('location'),
      loantypes: this.get('store').findAll('loanType'),
      reserve: this.get('store').createRecord('reserve', {
        biblio: biblio,
        user: user
      })
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