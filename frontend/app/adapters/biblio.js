import Ember from 'ember';
import applicationAdapter from './application';

export default applicationAdapter.extend({
  findRecord: function(store, type, id, snapshot) {
    if (snapshot.adapterOptions) {
      let url = this.buildURL(type.modelName, id, snapshot, 'findRecord');
      let query = {
        items_on_subscriptions: Ember.get(snapshot.adapterOptions, 'items_on_subscriptions')
      };
      return this.ajax(url, 'GET', { data: query });
    } else {
      return this._super(...arguments);
    }
  }
});