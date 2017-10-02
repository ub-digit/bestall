import DS from 'ember-data';

export default DS.Model.extend({

  user: DS.belongsTo('user', {async: false, inverse: null}),
  location: DS.belongsTo('location', {async: false, inverse: null}),
  loanType: DS.belongsTo('loan-type', {async: false, inverse: null}),
  biblio: DS.belongsTo('biblio', {async: false, inverse: null}),
  item: DS.belongsTo('item', {async: false, inverse: null}),
  subscription: DS.belongsTo('subscription', {async: false, inverse: null}),
  reserveNotes: DS.attr('string'),
  queuePosition: DS.attr('string'),

  subscriptionNotes: DS.attr('string'),
  subscriptionLocation: DS.attr('string'),
  subscriptionSublocationId: DS.attr('string'),
  subscriptionSublocation: DS.attr('string'),
  subscriptionCallNumber: DS.attr('string')

});
