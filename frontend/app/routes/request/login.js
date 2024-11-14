import Ember from 'ember';
import UnAuthenticatedRouteMixin from 'ember-simple-auth/mixins/unauthenticated-route-mixin'

export default Ember.Route.extend(UnAuthenticatedRouteMixin, {
  model: function(params, transition) {
    var biblioId = transition.params.request.id;
    this.get('store').createRecord('tmp_biblio', {id: 1, biblio: biblioId});
    //??
  },
  setupController: function(controller) {
    controller.set('showForm', true);
    controller.set('showSpinner', false);
  }
});
