import Ember from 'ember';

export default Ember.Component.extend({
  filteredLocations: Ember.computed('userCategory', 'locations', 'item.sublocation.isOpenLoc', 'item.sublocation.location', function() {
    let filteredLocations = this.get('locations');
    return filteredLocations;
  })
});