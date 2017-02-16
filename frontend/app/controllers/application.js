import Ember from 'ember';

export default Ember.Controller.extend({
	i18n: Ember.inject.service(),
	session: Ember.inject.service(),
	queryParams: ['lang'],
	lang: 'sv',
  // ticket: null,

	getLocale: Ember.computed('i18n.locale', 'i18n.locales', function() {
		return this.get('i18n.locale');
	}),

});
