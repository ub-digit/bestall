import Ember from 'ember';

export default Ember.Component.extend({

 // isVisible: Ember.computed.or('canBeQueued', 'canBeOrdered'),

  actions: {
    onOrderClick() {
      this.get('onClick')();
    }
  }
});
