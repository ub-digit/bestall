import Ember from 'ember';
import DS from 'ember-data';
import ENV from 'frontend/config/environment';

export default Ember.Route.extend({
	i18n: Ember.inject.service(),
	session: Ember.inject.service(),
	queryParams: {
	    lang: {
	     // refreshModel: true
	    }
  	},
  	

  casService: function() {
//    var baseUrl = window.location.origin + ENV.rootURL;
    var baseUrl = window.location.origin;
    var routeUrl = this.router.generate('application');
//    console.log('routeurl', routeUrl);
    return baseUrl + routeUrl;
  },


	model() {
		var that = this; 
		return Ember.RSVP.hash({
			config: that.store.find('config', 1),
			locations: that.store.findAll('location'),
			loantypes: that.store.findAll('loanType'),
		})
	},

	beforeModel(params) {
	    var that = this;
	    var session = this.get('session');
	    var ticket = params.queryParams.ticket;
	    var lang = params.queryParams.lang;


	    if(ticket) {
	      session.authenticate('authenticator:cas', {
	        cas_ticket: ticket,
	        cas_service: this.casService()
	      });
	    }

	    if(lang) {
	    	this.set('i18n.locale', lang);
	    }
	},

	setupController(controller, models) {
		if (models.config) {
			controller.set('config', models.config);
		}
		if (models.locations) {
			controller.set('locations', models.locations);
		}

		if (models.loantypes) {
			controller.set("loantypes", models.loantypes);
		}

	    controller.set('ticket', null);
	    // Set CAS login URL
	    // if (model && model.casUrl.cas_url) {
	    //   var casLoginUrl = model.casUrl.cas_url + '/login?'+Ember.$.param({service: this.casService()});
	    //   controller.set('casLoginUrl', casLoginUrl);
	    // }
	    var casLoginUrl = 'https://idp3.it.gu.se/idp/profile/cas' + '/login?'+Ember.$.param({service: this.casService()});
	    controller.set('casLoginUrl', casLoginUrl);
	},

  actions: {
  }
});
