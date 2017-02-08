import Ember from 'ember';

export default Ember.Component.extend({
	actions: {
		pickLocation(location) {
			this.set("selectedLocation", location);
		}
	}
});
