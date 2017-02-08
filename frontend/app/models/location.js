import DS from 'ember-data';

export default DS.Model.extend({
	name_sv: DS.attr(),
	name_en: DS.attr(),
});
