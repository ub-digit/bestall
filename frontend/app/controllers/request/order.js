import Ember from 'ember';

export default Ember.Controller.extend({
	i18n: Ember.inject.service(),
	// queryParams: ['location', 'type'],
	location: null,
	type: null
});
