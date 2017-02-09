import Ember from 'ember';

export default Ember.Route.extend({
	i18n: Ember.inject.service(),
	store: Ember.inject.service(),
	model() {
		return this.modelFor('order');
	},

	setupController(controller, model) {
		var temp = controller.get("application.loantypes").get("firstObject");
		controller.set("selectedLoantype", this.store.peekAll("loantype").get("firstObject").get("id"));
	},


	actions: {
		moveForward: function() {
			this.transitionTo("order.summary");
		}
	}
});
