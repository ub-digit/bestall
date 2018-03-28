import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),

  activeTabName: null,

  numSubscriptions: Ember.computed('request.model.biblio.subscriptiongroups', function() {
    let res = 0;
    var grps = this.get('request.model.biblio.subscriptiongroups');
    grps.map((obj) => {
      res += obj.get('subscriptions.length');
    });
    return res;
  }),

  activeTab: Ember.computed('request.model.biblio.subscriptiongroups', {
    get() {
      if (this.get("request.model.biblio.hasItemLevelQueue")) {
        if (this.get("request.model.biblio.subscriptiongroups.length")) {
          this.set("activeTabName", "tab1");
        } else {
          this.set("activeTabName", "tab2");
        }
      } else {
        this.set("activeTabName", "tab1");
      }
      return this.get("activeTabName");
    },
    set(key, value) {
      let activeName = value;
      this.set('activeTabName', activeName);
      return value;
    }
  }),

  showMyLoanMessage: Ember.computed(function() {
    return (this.get('request.view') !== '46GUB_KOHA');
  }),

  hasItemAvailableForOrder: Ember.computed('request.model.biblio.items', function() {
    if (this.get("itemsAvailableForOrder.length") > 0) {
      return true;
    }
    return false;
  }),

  itemsAvailable: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filter((item) => item.get("isAvailible"));
  }),

  itemsAvailableForOrder: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filter((item) => item.get("canBeOrdered"));
  }),

  itemsNotAvailable: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filter((item) => !item.get("isAvailible"));
  }),
  actions: {
    setItemToOrder(item) {
      this.get('order.model.reserve').set('item', item);
      this.get('order.model.reserve').set('subscription', null);
      this.get('order.model.reserve').set('subscriptionNotes', null);
      this.transitionToRoute('request.order.details');
    },
    setSubscriptionToOrder(subscription) {
      this.get('order.model.reserve').set('subscription', subscription);
      this.get('order.model.reserve').set('item', null);
      this.get('order.model.reserve').set('reserveNotes', null);

      this.transitionToRoute('request.order.details');
    },
    setActiveTab(tab) {
      this.set('activeTab', tab);
    }
  }

});