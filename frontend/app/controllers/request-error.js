import Ember from 'ember';

const {
    computed,
    inject
} = Ember;

export default Ember.Controller.extend({
    i18n : inject.service(),

    reason: computed('error_type', function(){

        
        const dictionary = this.get('i18n');
        const locale = this.get('i18n.locale');
        const errorCode = this.get('errorCode');
        // the node 'request-errors' in the locale files contains nodes corresponding to the error code.
        return dictionary.t('request-errors.' + errorCode);
    })
});

