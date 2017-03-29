import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),

  itemsThatCanBeOrdered: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filterBy('canBeOrdered', true);
  }),

  itemsThatCanBeQueed: Ember.computed('request.model.biblio.items', function() {
    return this.get("request.model.biblio.items").filterBy('canBeQueed', true);
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
    }
  }

});
