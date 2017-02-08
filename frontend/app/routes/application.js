import Ember from 'ember';
import DS from 'ember-data';
import ENV from 'frontend/config/environment';

export default Ember.Route.extend({
  queryParams: {
    lang: {
      refreshModel: true
    }
  },

  i18n: Ember.inject.service(),
  session: Ember.inject.service(),
  casService: function() {
    var baseUrl = window.location.origin + ENV.rootURL;
    var routeUrl = this.router.generate('application');
    console.log('routeurl', routeUrl);
    return baseUrl + '/' + routeUrl;
  },

  beforeModel(params) {
    if (params.queryParams.lang) {
      this.set("i18n.locale", params.queryParams.lang);
    }
  },

  setupController(controller, model) {
    controller.set('model', {});
    controller.set('ticket', null);
    // Set CAS login URL
    // if (model && model.casUrl.cas_url) {
    //   var casLoginUrl = model.casUrl.cas_url + '/login?'+Ember.$.param({service: this.casService()});
    //   controller.set('casLoginUrl', casLoginUrl);
    // }
    var casLoginUrl = 'https://idp3.it.gu.se/idp/profile/cas' + '/login?'+Ember.$.param({service: this.casService()});
    controller.set('casLoginUrl', casLoginUrl);
  },

  actions: {
  }
});
