import Ember from 'ember';

export default Ember.Route.extend({
    setupController(controller, errors) {
        controller.set('errors', errors.errors);
        if (errors.errors.data) {
            controller.set('data', errors.errors.data);
        }
        this._super(...arguments);
    }
});