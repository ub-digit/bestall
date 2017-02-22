import Ember from 'ember';
import ENV from 'frontend/config/environment';

export default Ember.Route.extend({
    beforeModel(transition){
        if(!transition.params.request){
            console.log('no request in params');
            this.replaceWith('error', {error:'error_msg'});
        }
    },
});
