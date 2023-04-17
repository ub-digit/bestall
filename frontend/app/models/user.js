import Ember from 'ember';
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
  warning: DS.attr('boolean'),

  deniedReasons: DS.attr(),
  warningReasons: DS.attr(),

  userCategory: DS.attr('string'),
  pickupCode: DS.attr('string')
});
