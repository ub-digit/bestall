import DS from 'ember-data';

export default DS.Model.extend({

  user: DS.belongsTo('user', {inverse: null}),
  location: DS.belongsTo('location', {inverse: null}),
  biblio: DS.belongsTo('biblio', {inverse: null}),
  item: DS.belongsTo('item', {inverse: null})

});
