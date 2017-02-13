import Ember from 'ember';

export default Ember.Controller.extend({
	application: Ember.inject.controller(),
	order: Ember.inject.controller(),

	pickupLocation: Ember.computed('order.location', function() {
		let locations = this.get("application.locations");
		let location = locations.findBy("id", this.get("order.location"));
		return location.get("name");
	}),	

	typeOfLoan: Ember.computed('order.type', function() {
		let locations = this.get("application.loantypes");
		let location = locations.findBy("id", this.get("order.type"));
		return location.get("name");
	}),	

});
