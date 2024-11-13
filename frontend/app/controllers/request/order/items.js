import Ember from 'ember';

export default Ember.Controller.extend({

  order: Ember.inject.controller('request.order'),
  activeTabName: null,
  isReservedClick: false,
  isReservedClicked: Ember.observer('isReservedClick', function() {
    // deal with the change
    this.get('order.model.reserve').set('isReservedClicked', this.get('isReservedClick'));
  }),
  numSubscriptions: Ember.computed('order.model.biblio.subscriptiongroups', function() {
    let res = 0;
    var grps = this.get('order.model.biblio.subscriptiongroups');
    grps.map((obj) => {
      res += obj.get('subscriptions.length');
    });
    return res;
  }),

  activeTab: Ember.computed('order.model.biblio.subscriptiongroups', {
    get() {
      if (this.get("order.model.biblio.hasItemLevelQueue")) {
        if (this.get("order.model.biblio.subscriptiongroups.length")) {
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

  hasItemAvailableForOrder: Ember.computed('order.model.biblio.items', function() {
    if (this.get("itemsAvailableForOrder.length") > 0) {
      return true;
    }
    return false;
  }),

  itemsAvailable: Ember.computed('order.model.biblio.items', function() {
    return this.get("order.model.biblio.items").filter((item) => item.get("isAvailible"));
  }),

  itemsAvailableForOrder: Ember.computed('order.model.biblio.items', function() {
    return this.get("order.model.biblio.items").filter((item) => item.get("canBeOrdered"));
  }),

  itemsNotAvailable: Ember.computed('order.model.biblio.items', function() {
    return this.get("order.model.biblio.items").filter((item) => !item.get("isAvailible"));
  }),
  actions: {
    setItemToOrder(item, isReservedClicked) {
      if (isReservedClicked) {
        this.set('isReservedClick', true);
      }
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
