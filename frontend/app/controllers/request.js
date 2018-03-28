import Ember from 'ember';

export default Ember.Controller.extend({
  queryParams: ['ticket', 'forceSSO', 'SSOscanner', 'view'],
  ticket: null,
  forceSSO: null,
  SSOscanner: null,
  view: null
});
