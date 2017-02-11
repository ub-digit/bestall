import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
    this.route('order', { path: ':id' }, function() {
        this.route("start");
        this.route('summary');
        this.route('confirmation');
        
        this.route("foo");
        this.route("bar");
    });
    
});

export default Router;
