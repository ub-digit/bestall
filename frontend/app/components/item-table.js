import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    setItemToOrder(item) {
      this.get('setItemToOrder')(item);
    },
    togglePublicNote() {
      $('.public-note').slideToggle(200);
      $('.ub-close').toggleClass('expanded');
    }
  }
});
