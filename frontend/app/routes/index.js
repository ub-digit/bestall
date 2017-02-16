import Ember from 'ember';
import ENV from 'frontend/config/environment';

export default Ember.Route.extend({
    beforeModel(transition){
        if(!transition.params.request.id){
            this.intermediateTransitionTo('error', true);
        }
    }
});
