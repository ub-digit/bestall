import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),

  pickupLocations: Ember.computed.filterBy('order.model.locations', 'isPickupLocation', true),

  btnNextDisabled: Ember.computed('order.model.reserve.{location,loanType}', function() {
		if (this.get('order.model.reserve.location') && this.get('order.model.reserve.loanType')){
			return false;
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
    },
    moveForward() {
      if (this.get('order.model.reserve.subscription')) {
        this.get('order.model.reserve').set('subscriptionLocation', this.get('order.model.reserve.subscription.sublocation.location.name'));
        this.get('order.model.reserve').set('subscriptionSublocation', this.get('order.model.reserve.subscription.sublocation.name'));
        this.get('order.model.reserve').set('subscriptionCallNumber', this.get('order.model.reserve.subscription.callNumber'));
      }
      this.transitionToRoute('request.order.summary');
    }
  }

});
