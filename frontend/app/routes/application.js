import Ember from 'ember';

export default Ember.Route.extend({
	i18n: Ember.inject.service(),
	session: Ember.inject.service(),

	beforeModel(transition) {
		var lang = transition.queryParams.lang;

    if(lang) {
    	this.set('i18n.locale', lang);
    }
	},

	model() {
		return this.store.find('config', 1);
	}
});
