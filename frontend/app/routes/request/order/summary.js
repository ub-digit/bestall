import Ember from 'ember';

export default Ember.Route.extend({

  actions: {
		moveForward() {
			this.transitionTo('request.order.confirmation');
		}
	}
});
