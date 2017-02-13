import Ember from 'ember';

export default Ember.Route.extend({

	model(params) {
		return this.modelFor('order');
	},

	actions: {
		moveForward() {
			this.transitionTo('order.confirmation');
		}
	}
});
