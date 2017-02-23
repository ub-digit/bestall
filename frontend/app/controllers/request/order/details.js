import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),

  btnNextDisabled: Ember.computed('order.model.reserve.{location,loanType}', function() {
		if (this.get('order.model.reserve.location') && this.get('order.model.reserve.loanType')){
			return false
		}
		return true;
	}),

  actions: {
    setLocation(id) {
      let location = this.get('store').peekRecord('location', id);
      this.get('order.model.reserve').set('location', location);
    },

    setLoanType(id) {
      let loanType = this.get('store').peekRecord('loanType', id);
      this.get('order.model.reserve').set('loanType', loanType);
    }
  }

});
