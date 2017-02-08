import DS from 'ember-data';
import Application from 'frontend/adapters/application';

export default Application.extend({
  pathForType: function(type) {
  	if (type === "config") {
    	return type;
    }
  },
});