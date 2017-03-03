import Ember from 'ember';

export default Ember.Route.extend({
    setupController(controller, errors){
        controller.set('errors', errors.errors);
        controller.set('data', errors.errors.data);
        this._super(...arguments);
    }
});
