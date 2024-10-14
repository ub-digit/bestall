import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params, transition) {
    var biblioId = transition.params.request.id;
    this.get('store').createRecord('tmp_biblio', {id: 1, biblio: biblioId});
    //??
  },
  setupController: function(controller) {
    controller.set('showForm', true);
  },

});
