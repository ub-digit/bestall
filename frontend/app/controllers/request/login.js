import Ember from 'ember';

export default Ember.Controller.extend({
  i18n: Ember.inject.service(),
  session: Ember.inject.service(),
  request: Ember.inject.controller(),
  showForm: false,
  getLocale: Ember.computed('i18n.locale', 'i18n.locales', function() {
    return this.get('i18n.locale');
  }),

  actions: {
    login() {
      let { username, password } = this.getProperties('username', 'password');
      this.get('session')
        .authenticate('authenticator:librarycard', { username: username, password: password })
        .catch((reason) => {
          this.set('errorMessage', reason.error || reason);
        });
    },
    loginOAuth2() {
      return this.get('session')
        .authenticate('authenticator:torii', 'gub')
        .catch((reason) => {
          //let message = typeof reason === 'string' ? reason : 'Unknown server error';
          this.set('errorMessage', true);
        });
    },
  },
  inputAutocomplete: Ember.computed(function() {
    return (this.get('request.view') !== '46GUB_KOHA');
  }),
  libraryCardUrl: Ember.computed(function() {
    var lang = this.get('getLocale');
    return this.get('store').peekRecord('config', 1).get('registrationurl') + '?lang=' + lang;
  })
});
