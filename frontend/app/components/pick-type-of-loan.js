import Ember from 'ember';

export default Ember.Component.extend({
	actions: {
		pickType(type) {
			this.set("selectedLoantype", type);
		}
	}
});
