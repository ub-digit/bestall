import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),
  i18n: Ember.inject.service(),
  btnSubmitOrderDisabled: false,

  getOrderButtonText: Ember.computed('btnSubmitOrderDisabled', function() {
    if (this.get('btnSubmitOrderDisabled') == true) {
      return this.get('i18n').t('request.order.summary.submitting-order-button');
    }
    else {
      return this.get('i18n').t('request.order.summary.submit-order-button');
    }
  }),
});
