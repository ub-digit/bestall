import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  i18n: Ember.inject.service(),

  sublocations: DS.hasMany('sublocation'),
  nameSv: DS.attr('string'),
  nameEn: DS.attr('string'),
  categories: DS.attr(),

  name: Ember.computed('i18n.locale', function() {
    if (this.get('i18n.locale') === 'sv') {
      return this.get('nameSv');
    }
    return this.get('nameEn');
  }),

  isPickupLocation: Ember.computed('categories', function() {
    return this.get('categories').includes('PICKUP');
  }),

  pickupLocationClosed: Ember.computed('categories', function() {
    return this.get('categories').includes('CLOSED');
  })
});