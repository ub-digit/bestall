import Ember from 'ember';

const {
  computed,
  inject
} = Ember;

export default Ember.Controller.extend({
  i18n: inject.service(),
  request: inject.controller(),
  order: inject.controller('request.order'),

  hasItemLevelQueue: computed('order', function() {
    let res = this.get('order.model.reserve.biblio.hasItemLevelQueue');
    return res;
  }),

  showQueue: computed('order', function() {
    //let hasItemLevelQueue = this.get('hasItemLevelQueue');
    let hasSubscription = this.get('oder.model.reserve.subscription');
    return hasSubscription;
  }),

  reason: computed('order.errors', function() {
    const errors = this.get('order.errors');
    const dictionary = this.get('i18n');

    //const errorCodes = ['DAMAGED', 'AGE_RESTRICTED', 'ITEM_ALREADY_ON_HOLD', 'TOO_MANY_RESERVES', 'NOT_RESERVABLE', 'CANNOT_RESERVE_FROM_OTHER_BRANCHES', 'TOO_MANY_HOLDS_FOR_THIS_RECORD', 'BORROWER_NOT_FOUND', 'BRANCH_CODE_MISSING', 'ITEMNUMBER_OR_BIBLIONUMBER_IS_MISSING', 'BIBLIONUMBER_IS_MISSING', 'ITEM_DOES_NOT_BELONG_TO_BIBLIO', 'UNRECOGNIZED_ERROR', 'MISSING_USER', 'MISSING_LOCATION', 'MISSING_BIBLIO', 'MISSING_LOAN_TYPE'];
    let res = '';
    if (!errors.errors) {
      return '';
    }
    errors.errors.map((obj) => {
      const msg = dictionary.t('confirmation-errors.' + obj.code + '.message');
      res += `<p>${msg}</p>`;
    });
    return res;

  })

});