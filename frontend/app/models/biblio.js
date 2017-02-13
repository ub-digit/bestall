import DS from 'ember-data';

export default DS.Model.extend({
	title: DS.attr(),
	canBeOrdered: DS.attr(),
	author: DS.attr()
});
