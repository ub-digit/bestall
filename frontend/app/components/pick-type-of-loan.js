import Ember from 'ember';

export default Ember.Component.extend({
	actions: {
		setValue: function(value, event) {
			this.set("selectedItem", value);
		}
	}
});
