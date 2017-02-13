import Ember from 'ember';


export default Ember.Controller.extend({
	i18n: Ember.inject.service(),
	application: Ember.inject.controller(),
	queryParams: ['location', 'type'],
	location: null,
	type: null,
});
