import Ember from 'ember';

export default Ember.Controller.extend({
	application: Ember.inject.controller(),
	order: Ember.inject.controller(),

	btnNextDisabled: Ember.computed('order.location', 'order.type', function() {
		if (this.get("order.location") && this.get("order.type")){
			return false
		}
		return true;
	}), 
});
