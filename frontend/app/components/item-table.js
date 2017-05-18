import Ember from 'ember';
import moment from 'moment';

export default Ember.Component.extend({
  i18n: Ember.inject.service(),

  StatusText: Ember.computed('items[]', function() {
    const dictionary = this.get('i18n');
    return this.get('items').map(function(item) {
      if (item.get('sublocation.isOpenLoc')) {
        item.set('sublocationText', item.get('sublocation.name') + ' ' + item.get('itemCallNumber'));
      }
      else {
        item.set('sublocationText', dictionary.t('components.item-table.must_be_ordered'));
      }

      item.set('locationText', item.get('location.name'));

      if (item.get('isAvailible') === true) {
        item.set('statusText', dictionary.t('components.item-table.available'));
        if (item.get('statusLimitation') === 'NOT_FOR_HOME_LOAN') {
          item.set('statusLimitationText', dictionary.t('components.item-table.not_for_home_loan'));
        }
        else if (item.get('statusLimitation') === 'READING_ROOM_ONLY') {
          item.set('statusLimitationText', dictionary.t('components.item-table.reading_room_only'));
        }
        else if (item.get('statusLimitation') === 'LOAN_IN_HOUSE_ONLY') {
          item.set('statusLimitationText', dictionary.t('components.item-table.loan_in_house_only'));
        }
      }

      else if (item.get('status') === 'LOANED') {
        item.set('statusText', dictionary.t('components.item-table.loaned') + ' ' + moment(item.get('dueDate')).format("YYYY-MM-DD"));
      }
      else if (item.get('status') === 'RESERVED') {
        item.set('statusText', dictionary.t('components.item-table.reserved'));
      }
      else if (item.get('status') === 'WAITING') {
        item.set('statusText', dictionary.t('components.item-table.waiting'));
      }
      else if (item.get('status') === 'IN_TRANSIT') {
        item.set('statusText', dictionary.t('components.item-table.in_transit'));
      }
      else if (item.get('status') === 'DELAYED') {
        item.set('statusText', dictionary.t('components.item-table.delayed'));
      }
      else if (item.get('status') === 'LOST') {
        item.set('statusText', dictionary.t('components.item-table.lost'));
      }
      else if (item.get('status') === 'DURING_ACQUISITION') {
        item.set('statusText', dictionary.t('components.item-table.under_acquisition'));
      }
      else if (item.get('status') === 'RECENTLY_RETURNED') {
        item.set('statusText', dictionary.t('components.item-table.recently_returned'));
      }
      else {
        item.set('statusText', dictionary.t('components.item-table.unknown'));
      }
      return item;

    });
  }),
  actions: {
    setItemToOrder(item) {
      this.get('setItemToOrder')(item);
    }
  }
});
