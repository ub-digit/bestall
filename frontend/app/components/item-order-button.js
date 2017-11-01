import Ember from 'ember';

export default Ember.Component.extend({

  isVisible: Ember.computed.or('canBeQueued', 'canBeOrdered', 'isAvailible'),

  actions: {
    onOrderClick() {
      this.get('onClick')();
    }
  }
});
