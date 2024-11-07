import Ember from 'ember';

export default Ember.Route.extend({
  session: Ember.inject.service(),

  beforeModel(transition) {

    // Special fix when the user is authenticated with CAS and the session is not valid anymore.
    // Check if there is as session object with a authenticated property with authenticator: "authenticator:cas",then remove/reset the session object and make a "hard" window reload.
    if (this.get('session.isAuthenticated') && this.get('session.data.authenticated.authenticator') === "authenticator:cas") {
      console.log("CAS session is not valid anymore, reloading the page.");
      console.log("Session: ", this.get('session'));
      this.get('session').invalidate();
      window.location.reload(true);
    }
    console.log("Session: ", this.get('session'));

    let biblioId = transition.params.request.id;

    if (biblioId === "error") {
      return new Ember.RSVP.Promise((resolve, reject) => {
        reject({errors: {errors: [{"code": 'NO_ID', "detail": "loreum"}]}});
      });
    }
    if (!this.get('session.isAuthenticated')) {
      this.replaceWith('request.login');
    }
    else {
      this.replaceWith('request.order.items');
    }
  },

  model(params) {
    if (this.get('session.isAuthenticated')) {
      return Ember.RSVP.hash({
        //@FIXME: this.get('store')?
        biblio: this.store.findRecord('biblio', params.id, {adapterOptions: {items_on_subscriptions: "true"}}),
        user: this.store.queryRecord('user', {biblio: params.id})
      });
    } else {
      return Ember.RSVP.hash({
        biblio: this.store.find('biblio', params.id)
      });
    }

  },

  setupController(controller, model) {
    controller.set('model', model);
  },
 });
