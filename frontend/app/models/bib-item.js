import DS from 'ember-data';

export default DS.Model.extend({
	title: DS.attr(),
	can_be_ordered: DS.attr(),
	author: DS.attr()
});
