import Ember from 'ember';

export default Ember.Route.extend({
	i18n: Ember.inject.service(),

	model(params) {
		if (params.id) {
			this.controllerFor("start").set("bibId", params.id);
		}
		//if !params.id {this.transitionTo()}
		//return this.get('store').find('post', params.id);
	},

	beforeModel() {

	},

	setupController(controller, model) {

	},

	actions: {

	}
});
