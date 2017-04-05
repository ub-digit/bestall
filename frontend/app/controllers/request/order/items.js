import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),

  activeTab: null,

  itemsAvailable: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filter((item, index, self) => !item.get("dueDate"));
    //return this.get("request.model.biblio.items").filterBy('dueDate');
  }),

  itemsNotAvailable: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filterBy('dueDate');
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
      this.transitionToRoute('request.order.details');
    },
    setActiveTab(tab) {
      this.set('activeTab', tab);
    }
  }

});