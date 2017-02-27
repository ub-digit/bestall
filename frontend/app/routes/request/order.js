import Ember from 'ember';
import RSVP from 'rsvp';

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
    let defaultLoanType = model.loantypes.get('firstObject');

    model.reserve.set('loanType', defaultLoanType);
    controller.set('model', model);
  },

  actions: {

		goBack() {
			window.history.back();
		},

    submitOrder() {
      this.controller.get('model.reserve').save().then(() => {
        console.log('success');
        this.transitionTo('request.order.confirmation');

      }, (error) => {
        console.log('error', error)
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
