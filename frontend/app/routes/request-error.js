import Ember from 'ember';

export default Ember.Route.extend({
    setupController(controller, error){
        controller.set('errors', error.errors);
    }
});
