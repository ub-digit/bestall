import Ember from 'ember';

export default Ember.Route.extend({
	i18n: Ember.inject.service(),
  	queryParams: {
		location: {
			replace: true
		},
		type: {
			replace: true
		}
	},
	model(params) {
		return this.store.find('bib_item', params.id);
	},
	setupController(controller, model) {
		Ember.run.later(function() {
			controller.set("type", "1");	// defaults to the first one in payload
		});
		
		if (model.get("can_be_ordered")) {
			// if not authenticated redirect to CAS-login
			controller.set("model", model);
		}
		else {
			controller.set("model", model);
		}
	},

	actions: {
		goBack: function() {
			window.history.back();
		}
	}

});
