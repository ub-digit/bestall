import Ember from 'ember';
import DS from 'ember-data';
import ENV from 'frontend/config/environment';

export default Ember.Route.extend({
	queryParams: {
	    lang: {
	      refreshModel: true
	    }
  	},
  	
	i18n: Ember.inject.service(),

	beforeModel(params) {
		if (params.queryParams.lang) {
			this.set("i18n.locale", params.queryParams.lang)
		}
	},

	setupController(controller) {
	},

	actions: {
  	}
});
