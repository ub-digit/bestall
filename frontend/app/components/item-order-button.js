import Ember from 'ember';

export default Ember.Component.extend({
  isVisible: Ember.computed.or('canBeQueued', 'canBeOrdered', 'isAvailible'),

  actions: {
    onOrderClick(isReserve) {
      if (isReserve) {
        this.set("isReservedClick", true);
      }
      else {
        this.set("isReservedClick", false);
      }
      
      this.get('onClick')();
    }
  }
});
