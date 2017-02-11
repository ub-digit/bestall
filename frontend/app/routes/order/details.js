import Ember from 'ember';

export default Ember.Route.extend({
	i18n: Ember.inject.service(),
	store: Ember.inject.service(),

	model() {
		return this.modelFor('order');
	},

	setupController(controller, model) {
		controller.set("model", model);
		//var first = controller.get("application.loantypes").get("firstObject");
	},


	actions: {
		moveForward: function() {
			this.transitionTo('order.summary');
		}
	}
});
