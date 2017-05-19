import Ember from 'ember';

export default Ember.Component.extend({
  i18n: Ember.inject.service(),

  StatusText: Ember.computed('items[]', function() {
    return this.get('items').map(function(item) {
      item.set('statusText', this.get('i18n').t('componentsitem-table.'+ item.status));
      return item;
    });
  }),
  actions: {
    setItemToOrder(item) {
      this.get('setItemToOrder')(item);
    }
  }
});
