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

  beforeModel() {
    /* WORKAROUND! NO SOLUTION KNOWN!
     * Check if user is available (login has occurred) and 
     * session is unauthenticated (Chrome lost authentication for some reason).
     * 
     * If true, reject with an error so that the default error page can present
     * a message about trying another browser.
     */
    let user = this.modelFor('request').user;
    if (user && !this.get('session.isAuthenticated')) {
      return Ember.RSVP.reject({errors: {errors: [{code: 'BROWSER_ERROR', data: 'Unknown browser error'}]}});
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
