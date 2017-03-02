import Ember from 'ember';

export default Ember.Controller.extend({

  queryParams: ['ticket', 'forceSSO', 'SSOscanner'],
  ticket: null,
  forceSSO: null,
  SSOscanner: null
});
