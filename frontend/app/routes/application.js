import Ember from 'ember';

export default Ember.Route.extend({
	i18n: Ember.inject.service(),
	session: Ember.inject.service(),

	beforeModel(transition) {
		var lang = transition.queryParams.lang;

	    if(!transition.params.request){
	      //  console.log('no request in params');
	        //this.replaceWith('error', {error:'error_msg'});
	        this.transitionTo('request','error');
	    }

	    if(lang) {
	    	this.set('i18n.locale', lang);
	    }
	},

	model() {
		return this.store.find('config', 1);
	},


	actions: {
	
	}
});
