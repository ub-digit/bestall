import DS from 'ember-data';

export default DS.Model.extend({
	i18n: Ember.inject.service(),
	//id: DS.attr('string'),
	name_sv: DS.attr(),
	name_en: DS.attr(),

	name: Ember.computed('i18n.locale', function() {
		if (this.get("i18n.locale") === "sv"){
			return this.get("name_sv");
		}
		return this.get("name_en");
	})
});
