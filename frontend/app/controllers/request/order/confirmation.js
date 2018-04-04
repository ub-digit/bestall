import Ember from 'ember';

const {
  computed,
  inject
} = Ember;

export default Ember.Controller.extend({
  i18n: inject.service(),
  request: inject.controller(),
  order: inject.controller('request.order'),

  hasItemLevelQueue: computed('order.model.reserve.biblio.hasItemLevelQueue', function() {
    let res = this.get('order.model.reserve.biblio.hasItemLevelQueue');
    return res;
  }),

  hasSubscription: computed('order.model.reserve.subscription', function() {
    let hs = this.get('order.model.reserve.subscription');
    if (hs) {
      return true;
    }
    return false;
  }),

  showQueue: computed('hasItemLevelQueue', 'hasSubscription', function() {

    let itemLevelQ = this.get('hasItemLevelQueue');
    let hasSub = this.get('hasSubscription');
    if (itemLevelQ || hasSub) {
      return false;
    }
    return true;
  }),

  getLocale: Ember.computed('i18n.locale', 'i18n.locales', function() {
    return this.get('i18n.locale');
  }),

  showMyLoanUrl: Ember.computed(function() {
    return (this.get('request.view') !== '46GUB_KOHA');
  }),

  getMyLoanUrl: computed('order.model', function() {
    var lang = this.get('getLocale');
    return this.get('store').peekRecord('config', 1).get('myloansurl') + '?lang=' + lang;
  }),


  reason: computed('order.errors', function() {
    const errors = this.get('order.errors');
    const dictionary = this.get('i18n');

    let res = '';
    if (!errors.errors) {
      return '';
    }
    let eventLabel = '';
    errors.errors.map((obj) => {
      const msg = dictionary.t('confirmation-errors.' + obj.code + '.message');
      res += `<p>${msg}</p>`;
      eventLabel = eventLabel + ' ' + obj.code;
    });
    if (dataLayer) {
      dataLayer.push({'event' : 'GAEvent', 'eventCategory': 'Errors', 'eventAction': 'Confirmation error', 'eventLabel': eventLabel.trim()});
    }
    return res;
  })
});
