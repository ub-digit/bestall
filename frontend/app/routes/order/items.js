import Ember from 'ember';

export default Ember.Route.extend({

  actions: {
		moveForward: function() {
			this.transitionTo('order.details');
		}
	}
});
