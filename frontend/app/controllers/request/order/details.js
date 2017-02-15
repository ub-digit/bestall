import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),

  btnNextDisabled: Ember.computed('order.{location,type}', function() {
		if (this.get("order.location") && this.get("order.type")){
			return false
		}
		return true;
	})

});
