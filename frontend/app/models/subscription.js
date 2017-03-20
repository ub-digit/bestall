import DS from 'ember-data';

export default DS.Model.extend({

  biblio: DS.belongsTo('biblio'),
  sublocation: DS.belongsTo('sublocation'),
  callNumber: DS.attr('string'),
  publicNote: DS.attr('string')
});
