import Ember from 'ember';

export default Ember.Controller.extend({
	application: Ember.inject.controller(),
	queryParams: ['selectedLoantype', 'selectedLocation'],

	selectedLoantype: null,
	selectedLocation: null,

	btnNextDisabled: Ember.computed('selectedLocation', 'selecedLoantype', function() {
		if (this.get("selectedLocation") && this.get("selectedLoantype")){
			return false
		}
		return true;
	}), 

});
