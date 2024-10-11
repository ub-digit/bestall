import Ember from 'ember';
import ToriiAuthenticator from 'ember-simple-auth/authenticators/torii';
import config from 'frontend/config/environment';

export default ToriiAuthenticator.extend({
  torii: Ember.inject.service(),
  ajax: Ember.inject.service(),
  //store: Ember.inject.service(), //WTF?

  authenticate() {
    const ajax = this.get('ajax');
    const tokenExchangeUri = config.torii.providers['gub-oauth2'].tokenExchangeUri;

    return this._super(...arguments).then((data) => {
      return ajax.request(tokenExchangeUri, {
        type: 'POST',
        crossDomain: true,
        dataType: 'json',
        contentType: 'application/json',
        data: JSON.stringify({
          code: data.authorizationCode
        })
      }).then((response) => {
        var token = response.access_token;
        //this.get('store').createRecord('token', {id: 1, token: token}); //WTF?
        return {
          authenticated: true,
          token: token,
          provider: data.provider
        };
      }).catch((error) => {
        if ('payload' in error && 'errors' in error.payload) {
          throw error.payload.errors.detail;
        }
        else {
          throw error;
        }
      });
    });
  },
});
