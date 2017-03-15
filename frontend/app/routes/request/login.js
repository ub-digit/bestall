import Ember from 'ember';

export default Ember.Route.extend({
  loginCheckLoop: null,
  checkLoginOk: function(resolve, biblioId) {
    this.loginCheckLoop = Ember.run.later(() => {
      if(localStorage.getItem('login-check') === 'inner-login-ok') {
        localStorage.removeItem('login-check');
        localStorage.setItem('logged-in-ok', 'success');
        window.location.href = this.casLoginUrl() + '?' + Ember.$.param({service: this.returnUrl(biblioId)});
        //this.transitionTo('request.order.items', biblioId);
        return;
      } else {
        localStorage.setItem('logged-in-ok', 'no');
        this.checkLoginOk(resolve, biblioId);
      }
    }, 300);
  },
  model: function(params, transition) {
    var biblioId = transition.params.request.id;

    return new Ember.RSVP.Promise((resolve, reject) => {
      localStorage.removeItem('login-check');
      this.checkLoginOk(resolve, biblioId);
      Ember.run.later(() => {
        Ember.run.cancel(this.loginCheckLoop);
        if(localStorage.getItem('logged-in-ok') === 'no') {
          resolve();
        }
      }, 4000);
    });
  },
  setupController: function(controller, model) {
    controller.set('showForm', true);
    Ember.run.cancel(this.loginCheckLoop);
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
