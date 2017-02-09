import Ember from 'ember';

export default Ember.Controller.extend({
	application: Ember.inject.controller(),
	bibId: null,

	btnNextDisabled: Ember.computed('application.selectedLocation', 'application.selecedLoantype', function() {
		if (this.get("application.selectedLocation") && this.get("application.selectedLoantype")){
			return false
		}
		return true;
	}), 

});
