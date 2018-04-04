import Ember from 'ember';

const {
  computed,
  inject
} = Ember;

export default Ember.Controller.extend({
  i18n: inject.service(),

  reason: computed('errors', function() {
    const dictionary = this.get('i18n');
    // the node 'request-errors' in the locale files contains nodes corresponding to the error code.
    const errors = this.get('errors').errors;
    const header = dictionary.t('request-errors.header');
    let res = `<h3>${header}</h3>`;

    if (errors && errors.length > 0) {
      errors.map((obj) => {
        let eventLabel = '';
        if (obj.code) {
          let msg = dictionary.t('request-errors.' + obj.code + '.message');
          res += `<p>${msg}</p>`;
          eventLabel = eventLabel + ' ' + obj.code;
        }
        if (dataLayer) {
          dataLayer.push({'event' : 'GAEvent', 'eventCategory': 'Errors', 'eventAction': 'Request error', 'eventLabel': eventLabel.trim()});
        }
      });
    } else {
      res += dictionary.t('request-errors.UNKNOWN_ERROR.message');
      if (dataLayer) {
        dataLayer.push({'event' : 'GAEvent', 'eventCategory': 'Errors', 'eventAction': 'Request error', 'eventLabel': 'UNKNOWN_ERROR'});
      }
    }
    return res;
  })
});
