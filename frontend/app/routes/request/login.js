import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params, transition) {
    var biblioId = transition.params.request.id;

    return new Ember.RSVP.Promise((resolve) => {
      localStorage.removeItem('login-check');
      resolve();
    });
  },
  setupController: function(controller) {
    controller.set('showForm', true);
  },

  returnUrl: function(id) {
    let baseUrl = window.location.origin;
    let routeUrl = this.router.generate('request', {id: id}, {queryParams: {SSOscanner: null}});
    return baseUrl + routeUrl;
  },
  casLoginUrl() {
    return this.get('store').peekRecord('config', 1).get('casurl') + '/login';
  }

});
