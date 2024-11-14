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
      this.set('oauth2ErrorMessage', false);
      this.set('usernamePasswordErrorMessage', false);
      let { username, password } = this.getProperties('username', 'password');
      this.get('session')
        .authenticate('authenticator:librarycard', { username: username, password: password })
        .catch((reason) => {
          this.set('usernamePasswordErrorMessage', this.get('i18n').t('request.login.username-password-error'));
        });
    },
    loginOAuth2() {
      this.set('oauth2ErrorMessage', false);
      this.set('usernamePasswordErrorMessage', false);
      return this.get('session')
        .authenticate('authenticator:torii', 'gub')
        .catch((reason) => {
          this.set('oauth2ErrorMessage', this.get('i18n').t('request.login.oauth2-error'));
        });
    },
  },
  inputAutocomplete: Ember.computed(function() {
    return (this.get('request.view') !== '46GUB_KOHA');
  }),
  showGULogin: Ember.computed(function() {
    return (this.get('request.view') !== '46GUB_KOHA');
  }),
  libraryCardUrl: Ember.computed(function() {
    var lang = this.get('getLocale');
    return this.get('store').peekRecord('config', 1).get('registrationurl') + '?lang=' + lang;
  })
});
