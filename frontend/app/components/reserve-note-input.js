import Ember from 'ember';

export default Ember.Component.extend({

  inputLength: Ember.computed('value', function() {
    return this.get('value.length') || 0;
  }),

  isTextarea: Ember.computed('type', function() {
    if (this.get("type") === "textarea") {
      return true;
    }
    return false;
  })
});
