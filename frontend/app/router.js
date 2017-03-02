import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  


  this.route('request', { path: ':id' }, function() {
    this.route('order', function() {
      this.route('items');
      this.route('details');
      this.route('summary');
      this.route('confirmation');
    });
    
  });

  this.route('request-error');


});

export default Router;
