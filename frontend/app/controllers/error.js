import Ember from 'ember';

export default Ember.Controller.extend({
	i18n: Ember.inject.service(),

	is404: Ember.computed('model.status', function() {
		if (this.get('model.status') === '404') {
			return true;
		}
		return false;
	}),

	
	errorMessage: Ember.computed('model.status', function() {
		if (this.get('model.status') === '404') {
			return this.get("i18n").t('status-errors.404');
		}
	})


});
