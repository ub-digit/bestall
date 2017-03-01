import Ember from 'ember';
import ENV from 'frontend/config/environment';

export default Ember.Route.extend({

	setupController(controller, error) {
		console.log("error", error);
	}
});
