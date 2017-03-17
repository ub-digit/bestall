import Ember from 'ember';

export default Ember.Component.extend({
	filteredLocations: Ember.computed('userCategory', 'locations', 'item.sublocation.isOpenLoc', 'item.sublocation.location', function(){
        let filteredLocations = this.get('locations');

        if (this.get('canPickupFromAll')) {
             return filteredLocations;
        }
        if (this.get('item.sublocation.isOpenLoc')) {
            filteredLocations = filteredLocations.filter((item) => {
                if(item.id !== this.get('item.sublocation.location.id')){
                    return item;
                }
            });
        }
        return filteredLocations;

    }),

    canPickupFromAll: Ember.computed('userCategory', function(){
        const match = 'FI SY FY';
        return (match.indexOf(this.get('userCategory'))> -1);
    })

});

