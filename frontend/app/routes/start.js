import Ember from 'ember';

export default Ember.Route.extend({
	i18n: Ember.inject.service(),

	model(params) {
		if (params.id) {
			//this.controllerFor("start").set("bibId", params.id);
			return this.store.find('bib_item', params.id);
		}
		//if !params.id {this.transitionTo()}
		//return this.get('store').find('post', params.id);
	},

	beforeModel() {

	},

	setupController(controller, model) {
		if (model.get("can_be_ordered")) {
			// if not authenticated redirect to CAS-login
			controller.set("model", model);
		}
		else {
			controller.set("model", model);
		}
	},

	actions: {
		moveForward: function() {
			alert("transitionTo NEXT");
		}

	}
});
