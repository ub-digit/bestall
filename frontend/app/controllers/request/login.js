import Ember from 'ember';
import ENV from 'frontend/config/environment';

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
      this.set('loginErrorMessage', false);
      let { username, password } = this.getProperties('username', 'password');
      this.get('session')
        .authenticate('authenticator:librarycard', { username: username, password: password })
        .catch((reason) => {
          if (ENV.pinCodeActive === 'true') {
            this.set('loginErrorMessage', this.get('i18n').t('request.login.library-card-number-pin-code-login-error'));
          } else {
            this.set('loginErrorMessage', this.get('i18n').t('request.login.library-card-number-password-login-error'));
          }
        });
    },
    loginOAuth2() {
      this.set('oauth2ErrorMessage', false);
      this.set('loginErrorMessage', false);
      this.set('showSpinner', true);
      return this.get('session')
        .authenticate('authenticator:torii', 'gub')
        .catch((reason) => {
          this.set('oauth2ErrorMessage', this.get('i18n').t('request.login.oauth2-error'));
          this.set('showSpinner', false);
        });
    },
  },
  inputAutocomplete: Ember.computed(function() {
    return (this.get('request.view') !== '46GUB_KOHA');
  }),
  showGULogin: Ember.computed(function() {
    return (this.get('request.view') !== '46GUB_KOHA');
  }),
  libraryCardUrl: Ember.computed('i18n.locale', 'i18n.locales', function() {
    var lang = this.get('getLocale');
    return this.get('store').peekRecord('config', 1).get('registrationurl') + '?lang=' + lang;
  }),
  pinCodeActive: Ember.computed(function() {
    return (ENV.pinCodeActive === 'true');
  }),
  pinCodeForgotLink: Ember.computed('i18n.locale', 'i18n.locales', function() {
    var lang = this.get('getLocale');
    return (lang === 'en') ? ENV.pinCodeForgotLinkEn : ENV.pinCodeForgotLinkSv;
  })
});
