import Ember from 'ember';

export default Ember.Route.extend({

    
    setupController(controller, model){
        console.log(model);
        controller.set('errorCode', model.errorCode);
    }
});
