import DS from 'ember-data';

export default DS.Model.extend({

  username: DS.attr(),
  firstName: DS.attr(),
  lastName: DS.attr(),
  fullName: Ember.computed('firstName', 'lastName', function() {
    return `${this.get('firstName')} ${this.get('lastName')}`;
  }),
  finesAmount: DS.attr('number'),
  expirationDate: DS.attr('date'),

  denied: DS.attr('boolean'),

  banned: DS.attr('boolean'), // @banned
  fines: DS.attr('boolean'), // @fines
  debarred: DS.attr('boolean'), // @debarred
  noAddress: DS.attr('boolean'), // @no_address
  cardLost: DS.attr('boolean'), // @card_lost
  expired: DS.attr('boolean'), //@expired

});
