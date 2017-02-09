import Ember from 'ember';

export default Ember.Route.extend({
	i18n: Ember.inject.service(),
  	

	model(params) {
		return this.store.find('bib_item', params.id);
	},

	setupController(controller, model) {
		if (model.get("can_be_ordered")) {
			// if not authenticated redirect to CAS-login
			controller.set("model", model);
		}
		else {
			controller.set("model", model);
		}
	}

});
