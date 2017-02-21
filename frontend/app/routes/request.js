import Ember from 'ember';

export default Ember.Route.extend({
  session: Ember.inject.service(),

  beforeModel(transition) {
    let ticket = transition.queryParams.ticket;
    let biblioId = transition.params.request.id;

    if (ticket) {
      return new Ember.RSVP.Promise((resolve) => {
        this.get('session').authenticate('authenticator:cas', {
          cas_ticket: ticket,
          cas_service: this.returnUrl(biblioId)
        }).then(() => {
          resolve();
        });
      });
    }
  },

  model(params) {

    if (this.get('session.isAuthenticated')) {
      let username = this.get('session.data.authenticated.username');
      return Ember.RSVP.hash({
        biblio: this.store.find('biblio', params.id),
        user: this.store.queryRecord('user', {})
      });
    } else {
      return Ember.RSVP.hash({
        biblio: this.store.find('biblio', params.id)
      });
    }

	},

  afterModel(model, transition) {
    let ticket = transition.queryParams.ticket;
    let biblioId = transition.params.request.id;

    if (!ticket) {
      let url = this.casLoginUrl() + '?' + Ember.$.param({service: this.returnUrl(biblioId)});
      window.location.replace(url);
      return;
    }

    // TODO: inspect model to assess if Biblio can be ordered
    this.replaceWith('request.order.items');

  },

  setupController(controller, model) {
    controller.set('ticket', null);
    controller.set('model', model);
  },

  returnUrl(id) {
    let baseUrl = window.location.origin;
    let routeName = this.get('routeName');
    let routeUrl = this.router.generate(routeName, {id: id});
    return baseUrl + routeUrl;
  },

  casLoginUrl() {
    return this.get('store').peekRecord('config', 1).get('casurl') + '/login';
  }
});
