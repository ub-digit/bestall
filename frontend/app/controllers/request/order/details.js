import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller(),
  order: Ember.inject.controller('request.order'),

  possiblePickupLocations: Ember.computed.filterBy('order.model.locations', 'isPickupLocation', true),

  pickupLocations: Ember.computed('order', 'possiblePickupLocations', function() {

    // the current users userCategory
    const userCategory = this.get('order.model.reserve.user.userCategory');
    //All possible pickup locations
    let locations = this.get('possiblePickupLocations');
    let entity = this.get('order.model.reserve.subscription') ? this.get('order.model.reserve.subscription') : this.get('order.model.reserve.item');
    // if there is no item or subscription return all pickup locations
    if (!entity) {
      return locations;
    }

    let isOpenLoc = entity.get('sublocation.isOpenLoc');
    let isOpenPickupLoc = entity.get('sublocation.isOpenPickupLoc');
    // I items is OPEN_PICKUP_LOC, return all locations.
    // Nope, item can be booth OPEN_LOC and OPEN_PICKUP_LOC.
    if (isOpenPickupLoc) {
      return locations;
    }
    if (isOpenLoc) {
      // Only FI, SY, FU users can pickup items at its home/current location, thus return all locations
      if (['FI', 'SY', 'FY'].includes(userCategory)) {
        return locations;
      } else {
        // Elser filter out the home/current location from available locations

        const homeLocation = entity.get('sublocation.location.id');
        const filteredLocations = [];
        locations.map((item) => {
          item.set('disabled', false);
          const id = item.get('id');
          if (id == homeLocation) {
            item.set('disabled', true);

          }
          filteredLocations.push(item);
        });
        return filteredLocations;
      }
    } else {
      return locations;
    }

  }),

  btnNextDisabled: Ember.computed('order.model.reserve.{location,loanType}', function() {
    if (this.get('order.model.reserve.location') && this.get('order.model.reserve.loanType')) {
      return false;
    }
    return true;
  }),

  actions: {
    setLocation(id) {
      let location = this.get('store').peekRecord('location', id);
      this.get('order.model.reserve').set('location', location);
    },

    setLoanType(id) {
      let loanType = this.get('store').peekRecord('loanType', id);
      this.get('order.model.reserve').set('loanType', loanType);
    },
    moveForward() {
      if (this.get('order.model.reserve.subscription')) {
        this.get('order.model.reserve').set('subscriptionLocation', this.get('order.model.reserve.subscription.sublocation.location.name'));
        this.get('order.model.reserve').set('subscriptionSublocation', this.get('order.model.reserve.subscription.sublocation.name'));
        this.get('order.model.reserve').set('subscriptionCallNumber', this.get('order.model.reserve.subscription.callNumber'));
      }
      this.transitionToRoute('request.order.summary');
    }
  }
});