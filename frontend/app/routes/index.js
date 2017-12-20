import Ember from 'ember';

export default Ember.Route.extend({
  beforeModel: function(){
    let token = this.store.peekRecord('token', 1);
    if (token) {
      let biblioId = this.store.peekRecord('tmp_biblio', 1).get('biblio');
      if (biblioId) {
        this.replaceWith('request', biblioId, {queryParams: {ticket: null}});
      }
    }
  }
});