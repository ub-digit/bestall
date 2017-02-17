import DS from 'ember-data';

export default DS.Model.extend({
	title: DS.attr(),
	canBeBorrowed: DS.attr(),
	author: DS.attr(),
	items: DS.hasMany('item')
});
