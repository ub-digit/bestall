import DS from 'ember-data';

export default DS.Model.extend({
	title: DS.attr(),
	author: DS.attr(),
	canBeQueued: DS.attr('boolean'),
	canBeQueuedOnItem: DS.attr('boolean'),
	recordType: DS.attr('string'),
	noInQueue: DS.attr('number'),
	items: DS.hasMany('item')
});
