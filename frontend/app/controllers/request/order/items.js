import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),

  activeTabName: null,


  activeTab: Ember.computed('request.model.biblio.subscriptions', {
    get() {
      if (this.get("request.model.biblio.hasItemLevelQueue")) {
        if (this.get("request.model.biblio.subscriptions.length")) {
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


  hasItemAvailableForOrder: Ember.computed('request.model.biblio.items', function() {
    if (this.get("itemsAvailableForOrder.length") > 0) {
      return true;
    }
    return false;
  }),


  subscriptionsSorted: Ember.computed.sort('request.model.biblio.subscriptions', function(a, b) {
    if (a.get("sublocation.name") > b.get("sublocation.name")) {
      return 1;
    } else if (a.get("sublocation.name") < b.get("sublocation.name")) {
      return -1;
    }
    return 0;
  }),

  itemsAvailable: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filter((item) => item.get("isAvailible"));
  }),

  itemsAvailableForOrder: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filter((item) => item.get("canBeOrdered"));
  }),


  sortProperties: ['canBeOrdered:desc'],
  itemsAvailableSorted: Ember.computed.sort('itemsAvailable', 'sortProperties'),


  itemsSorted: Ember.computed.sort('request.model.biblio.items', function(a, b) {
    if (a.get("sublocation.name") > b.get("sublocation.name")) {
      return 1;
    }
    if (a.get("sublocation.name") < b.get("sublocation.name")) {
      return -1;
    }
    if (a.get("copyNumber") && !b.get("copyNumber")) {
      return -1;
    }
    if (!a.get("copyNumber") && b.get("copyNumber")) {
      return 1;
    }
    if (!a.get("copyNumber") && !b.get("copyNumber")) {
      return 0;
    }
    return a.get("copyNumber").localeCompare(b.get("copyNumber"), undefined, { numeric: true, sensitivity: 'base' });
  }),

  itemsNotAvailable: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filter((item) => !item.get("isAvailible"));
  }),


  itemsNotAvailableSorted: Ember.computed.sort('itemsNotAvailable', function(a, b) {
    let first = null;
    let second = null;
    if (!a.get("dueDate")) {
      first = new Date("October 13, 2094 11:13:00");
    } else {
      first = a.get("dueDate");
    }

    if (!b.get("dueDate")) {
      second = new Date("October 13, 2094 11:13:00");
    } else {
      second = b.get("dueDate");
    }
    if (first > second) {
      return 1;
    } else if (first < second) {
      return -1;
    }
    return 0;
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