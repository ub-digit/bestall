import Ember from 'ember';
import DS from 'ember-data';
import moment from 'moment';

export default DS.Model.extend({
  i18n: Ember.inject.service(),

  biblio: DS.belongsTo('biblio'),
  sublocation: DS.belongsTo('sublocation'),
  canBeOrdered: DS.attr('boolean'),
  canBeQueued: DS.attr('boolean'),
  itemType: DS.attr('string'),
  itemCallNumber: DS.attr('string'),
  copyNumber: DS.attr('string'),
  barcode: DS.attr('string'),
  status: DS.attr('string'),
  statusLimitation: DS.attr('string'),
  dueDate: DS.attr('string'),
  notForLoan: DS.attr('string'),
  isReserved: DS.attr('boolean'),
  isAvailible: DS.attr('boolean'),

  sublocationText: Ember.computed('sublocation.isOpenLoc', 'sublocation.name', 'itemCallNumber', function() {
    const dictionary = this.get('i18n');
    if (this.get('sublocation.isOpenLoc')) {
      if (this.get('itemCallNumber')) {
        return this.get('sublocation.name') + ', ' + this.get('itemCallNumber');
      } else if (this.get('biblio.biblioCallNumber')) {
        return this.get('sublocation.name') + ', ' + this.get('biblio.biblioCallNumber');
      } else {
        return this.get('sublocation.name');
      }
    } else {
      return dictionary.t('components.item-table.must_be_ordered');
    }
  }),

  statusLimitationText: Ember.computed('statusLimitation', function() {
    const dictionary = this.get('i18n');
    if (this.get('statusLimitation') === 'NOT_FOR_HOME_LOAN') {
      return dictionary.t('components.item-table.not_for_home_loan');
    } else if (this.get('statusLimitation') === 'READING_ROOM_ONLY') {
      return dictionary.t('components.item-table.reading_room_only');
    } else {
      return '';
    }
  }),

  statusText: Ember.computed('status', 'dueDate', function() {
    const dictionary = this.get('i18n');

    if (this.get('status') === 'LOANED') {
      return dictionary.t('components.item-table.loaned') + ' ' + this.get('dueDate').slice(0, -8); // + moment(this.get('dueDate')).format("YYYY-MM-DD");
    } else if (this.get('status') === 'RESERVED') {
      return dictionary.t('components.item-table.reserved');
    } else if (this.get('status') === 'WAITING') {
      return dictionary.t('components.item-table.waiting');
    } else if (this.get('status') === 'IN_TRANSIT') {
      return dictionary.t('components.item-table.in_transit');
    } else if (this.get('status') === 'DELAYED') {
      return dictionary.t('components.item-table.delayed');
    } else if (this.get('status') === 'DURING_ACQUISITION') {
      return dictionary.t('components.item-table.under_acquisition');
    } else if (this.get('status') === 'NOT_IN_PLACE') {
      return dictionary.t('components.item-table.not_in_place');
    } else if (this.get('status') === 'AVAILABLE') {
      return dictionary.t('components.item-table.available');
    } else {
      return dictionary.t('components.item-table.unknown');
    }
  }),

  actions: {
    setItemToOrder(item) {
      this.get('setItemToOrder')(item);
    }
  }
});
