import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    setItemToOrder(item) {
      this.get('setItemToOrder', item)();
    }
  }
});
