import Ember from 'ember';

export default Ember.Route.extend({
    setupController(controller, model){
        console.log('request error',model);
        controller.set('errors', model.errors);
    }
});
