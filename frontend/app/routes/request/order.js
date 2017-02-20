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
    return Ember.RSVP.hash({
      locations: this.get('store').findAll('location'),
      loantypes: this.get('store').findAll('loanType'),
      reserve: this.get('store').createRecord('reserve')
    });
  },

  setupController(controller, model) {

    controller.set('model', model);
    controller.set('type', '1');

  },

  actions: {
		goBack: function() {
			window.history.back();
		}
	}

});
