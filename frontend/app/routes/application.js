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

	model() {
		var that = this; 
		return Ember.RSVP.hash({
			casUrl: that.store.find('config', 'cas_url');
		})
	}

	beforeModel(params) {
		if (params.queryParams.lang) {
			this.set("i18n.locale", params.queryParams.lang)
		}
	},

	setupController(controller, models) {
		if (models.casUrl.cas_url) {
			let casLoginUrl = model.casUrl.cas_url;
			controller.set("casLoginUrl", casLoginUrl);
		}
	},

	actions: {
  	}
});
