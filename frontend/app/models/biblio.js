import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr('string'),
  origin: DS.attr('string'),
  isbn: DS.attr('string'),
  edition: DS.attr('string'),
  canBeQueued: DS.attr('boolean'),
  hasItemLevelQueue: DS.attr('boolean'),
  recordType: DS.attr('string'),
  noInQueue: DS.attr('number'),
  items: DS.hasMany('item'),
  subscriptions: DS.hasMany('subscription'),
  subscriptiongroups: DS.hasMany('subscriptiongroup')
});