import Ember from 'ember';
import ApplicationRouteMixin from 'ember-simple-auth/mixins/application-route-mixin';

export default Ember.Route.extend(ApplicationRouteMixin, {
	i18n: Ember.inject.service(),
	session: Ember.inject.service(),

	beforeModel(transition) {
    if(!transition.params.request){
      //  console.log('no request in params');
        //this.replaceWith('error', {error:'error_msg'});
        this.transitionTo('request','error');
    }

  	var lang = transition.queryParams.lang;
    if (!lang) {
      lang = localStorage.getItem('lang');
    }
	    if(lang) {
	    	localStorage.setItem('lang', lang);
	    	this.set('i18n.locale', lang);
	    }
	},

	model() {
		return this.store.find('config', 1);
	}

});
