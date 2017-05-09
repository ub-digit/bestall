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
        let res = `<h2>${header}</h2>`;


        if (errors && errors.length > 0) {
            errors.map((obj) => {
                if (obj.code) {
                    let msg = dictionary.t('request-errors.' + obj.code + '.message');
                    res += `<p>${msg}</p>`;
                }
            });
        } else {
            res += dictionary.t('request-errors.UNKNOWN_ERROR.message');;
        }
        return res;
    })
});
