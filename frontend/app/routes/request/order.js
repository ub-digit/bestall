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

    controller.set('model', model);
    controller.set('type', '1');

  },

  actions: {

		goBack() {
			window.history.back();
		},

    submitOrder() {
      this.controller.get('model.reserve').save().then(() => {
        console.log('success');
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
