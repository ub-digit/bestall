import DS from 'ember-data';

export default DS.Model.extend({

  biblio: DS.belongsTo('biblio'),
  sublocation: DS.belongsTo('sublocation'),
  canBeOrdered: DS.attr('boolean'),
  canBeQueued: DS.attr('boolean'),
  itemType: DS.attr('string'),
  itemCallNumber: DS.attr('string'),
  copyNumber: DS.attr('string'),
  barcode: DS.attr('string'),
  status: DS.attr('string'),
  dueDate: DS.attr('date'),
  status: DS.attr('string'),
  notForLoan: DS.attr('string')
});
