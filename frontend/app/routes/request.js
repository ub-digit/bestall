import Ember from 'ember';

export default Ember.Route.extend({
  session: Ember.inject.service(),

  beforeModel(transition) {
    let ticket = transition.queryParams.ticket;
    let biblioId = transition.params.request.id;
    let SSOscanner = transition.queryParams.SSOscanner;

    if (biblioId === "error") {
      return new Ember.RSVP.Promise((resolve, reject) => {
        reject({errors: {errors: [{"code": 'NO_ID', "detail": "loreum"}]}});
      });
    }

    if (ticket) {
      return new Ember.RSVP.Promise((resolve, reject) => {
        this.get('session').authenticate('authenticator:cas', {
          cas_ticket: ticket,
          cas_service: this.returnUrl(biblioId, SSOscanner)
        }).then(() => {
          // If this session is only used in the iframe to scan for successful SSO,
          // do not resolve the promise
          if(SSOscanner) {
            localStorage.setItem('login-check', 'inner-login-ok');
            // @FIXME: 'nope' value is never checked against elsewhere in the code?
            localStorage.setItem('logged-in-ok', 'nope');
          } else {
            resolve();
          }
        }, (reasons) => {
          reject({errors: {errors: [reasons.errors]}});
        });
      });
    }
  },

  model(params) {
    if (this.get('session.isAuthenticated')) {
      return Ember.RSVP.hash({
        //@FIXME: this.get('store')?
        biblio: this.store.find('biblio', params.id),
        user: this.store.queryRecord('user', {
          biblio: params.id
        })
      });
    } else {
      return Ember.RSVP.hash({
        biblio: this.store.find('biblio', params.id)
      });
    }

	},

  afterModel(model, transition) {
    let ticket = transition.queryParams.ticket;
    if (!ticket) {
      this.controllerFor('request').set('goToLogin', true);
    } else {
      // There is a ticket, login was successful.
      localStorage.setItem('login-check', 'inner-login-ok');
      localStorage.setItem('logged-in-ok', 'nope');
    }
  },

  setupController(controller, model) {
    controller.set('ticket', null);
    controller.set('model', model);

    if(controller.get('goToLogin')) {
      Ember.run.later(() => {
        controller.set('goToLogin', false);
      });
      this.transitionTo('request.login');
    } else {
      this.replaceWith('request.order.items');
    }
    controller.set('forceSSO', null);
    controller.set('SSOscanner', null);
  },

  returnUrl(id, SSOscanner) {
    let baseUrl = window.location.origin;
    let routeName = this.get('routeName');
    let routeUrl = this.router.generate(routeName, {id: id});
    if (SSOscanner) {
      routeUrl += '?SSOscanner=true';
    }
    return baseUrl + routeUrl;
  },

  casLoginUrl() {
    return this.get('store').peekRecord('config', 1).get('casurl') + '/login';
  }
});
