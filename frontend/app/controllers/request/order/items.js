import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),

  showQueueOnBiblio: Ember.computed('request.model.biblio.{canBeQueuedOnItem,canBeQueued}', function() {
    return !this.get('request.model.biblio.canBeQueuedOnItem') && this.get('request.model.biblio.canBeQueued');
  }),

  actions: {
    setItemToOrder(item) {
      this.get('order.model.reserve').set('item', item);
      this.transitionToRoute('request.order.details');
    }
  }

});
