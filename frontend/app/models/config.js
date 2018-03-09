import DS from 'ember-data';

export default DS.Model.extend({
  casurl: DS.attr(),
  registrationurl: DS.attr(),
  myloansurl: DS.attr()
});