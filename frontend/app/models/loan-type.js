import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
	i18n: Ember.inject.service(),
	nameSv: DS.attr(),
	nameEn: DS.attr(),

	name: Ember.computed('i18n.locale', function() {
		if (this.get("i18n.locale") === "sv"){
			return this.get("nameSv");
		}
		return this.get("nameEn");
	})
});
