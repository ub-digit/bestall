import Ember from 'ember';

export default Ember.Component.extend({
  isReservedButtonClicked: true, 
  isVisible: Ember.computed.or('canBeQueued', 'canBeOrdered', 'isAvailible'),

  actions: {
    onOrderClick(isReservedButtonClicked) {
      if (this.get("isReservedButtonClicked")) {
        this.set("isReservedClick", true);
      }
      else {
        this.set("isReservedClick", false);
      }
      
      this.get('onClick')();
    }
  }
});
