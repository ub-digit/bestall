import Ember from 'ember';
import DS from 'ember-data';
import ENV from 'frontend/config/environment';

export default Ember.Route.extend({
	queryParams: {
	    lang: {
	      refreshModel: true
	    },
	   /* selectedLocation: {
	    	refreshModel: true
	    }*/
  	},
  	
	i18n: Ember.inject.service(),

	model() {
		var that = this; 
		return Ember.RSVP.hash({
			config: that.store.find('config', 1),
			locations: that.store.findAll('location'),
			loantypes: that.store.findAll('loantype'),
		})
	},

	beforeModel(params) {
		if (params.queryParams.lang) {
			this.set("i18n.locale", params.queryParams.lang)
		}
	},

	setupController(controller, models) {
		if (models.config) {
			controller.set('config', models.config);
		}
		if (models.locations) {
			controller.set('locations', models.locations);
			// set selectedLocation to first object in array
			// this should maybe be more intelligent with localstorage och whatever
			controller.set('selectedLocation', models.locations.get('lastObject'));
		}

		if (models.loantypes) {
			controller.set("loantypes", models.loantypes);
			controller.set('selectedLoantype', models.loantypes.get('lastObject'));
		}
	},

	actions: {
  	}
});
