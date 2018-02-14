import DS from 'ember-data';

export default DS.Model.extend({
  shortInfo: DS.attr(),
  location: DS.belongsTo('location'),
  subscriptions: DS.hasMany('subscription'),
  biblio: DS.belongsTo('biblio')
});