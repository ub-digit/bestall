import Ember from 'ember';

export default Ember.Component.extend({

  isQueueable: Ember.computed.and('canBeQueuedOnItem', 'canBeQueued'),

  isVisible: Ember.computed.or('isQueueable', 'canBeOrdered'),

  actions: {
    onOrderClick() {
      this.get('onClick')();
    }
  }
});
