import Ember from 'ember';

export default Ember.Controller.extend({

  request: Ember.inject.controller('request'),
  order: Ember.inject.controller('request.order'),

  possiblePickupLocations: Ember.computed.filterBy('order.model.locations', 'isPickupLocation', true),

  inputAutocomplete: Ember.computed(function() {
    return (this.get('request.view') !== '46GUB_KOHA');
  }),


  displayTypeOfLoan: Ember.computed('order.model.reserve.isReservedClicked', function() {
    // typeofloan shoule not be displayed if user has clicked the reserve-button
    if (this.get("order.model.reserve.isReservedClicked")) {
      return false;
    }
    return true;
  }),

  applyFilter: Ember.computed('order.model.reserve.biblio', 'order.model.reserve.item', function() {
    let recordType = this.get('order.model.reserve.biblio.recordType');

    if (recordType === 'monograph' && (this.get('order.model.reserve.item') != null)) {
      //console.log('Reservationens biblio är en monografi OCH reservationen har ett exemplar. -> FILTRERA!');
      //console.log('Item ID: ' + this.get('order.model.reserve.item').id + ' Barcode: ' + this.get('order.model.reserve.item').barcode);
      return true;
    }
    if (recordType === 'serial' && (this.get('order.model.reserve.item') != null) && (this.get('order.model.reserve.item.canBeOrdered'))) {
      //console.log('Reservationens biblio är en periodika OCH reservationen har ett exemplar OCH reservationens exemplar kan beställas. -> FILTRERA!');
      //console.log('Item ID: ' + this.get('order.model.reserve.item').id + ' Barcode: ' + this.get('order.model.reserve.item').barcode);
      return true;
    }
    //console.log('Reservationen är kö eller beståndsbeställning. -> INGET FILTER!');
    return false;
  }),

  pickupLocations: Ember.computed('order.model.reserve.{subscription,user.userCategory,item}', 'possiblePickupLocations', 'applyFilter', function() {
    //console.log('DEBUG: IN pickupLocations');
    // the current users userCategory
    const userCategory = this.get('order.model.reserve.user.userCategory');
    //All possible pickup locations
    let locations = this.get('possiblePickupLocations');

    // Reset the items in the locations array since they might have been
    // disabled earlier.
    locations.map((item) => {
      item.set('disabled', false);
    });

    // If pickup location is closed, disable location in dropdown list
    locations.map((item) => {
      if (item.get('pickupLocationClosed')) {
        item.set('disabled', true);
      }
    });

    //let applyFilter = this.get('order.model.reserve.applyFilter');
    let filter = this.get('applyFilter');
    if (!filter) {
      //console.log('NO FILTER!!! -> applyFilter is ' + filter);
      return locations;
    } else {
      //console.log('APPLY THE FILTER!!! -> applyFilter is ' + filter);
    }

    let entity = this.get('order.model.reserve.subscription') ? this.get('order.model.reserve.subscription') : this.get('order.model.reserve.item');
    // if there is no item or subscription return all pickup locations
    if (!entity) {
      //console.log('DEBUG: No Entity -> no subscription and no item');
      return locations;
    }

    let isOpenLoc = entity.get('sublocation.isOpenLoc');
    let isOpenPickupLoc = entity.get('sublocation.isOpenPickupLoc');
    //console.log('DEBUG: isOpenPickupLoc==' + isOpenPickupLoc);
    //console.log('DEBUG: isOpenLoc==' + isOpenLoc);
    // I items is OPEN_PICKUP_LOC, return all locations.
    // Nope, item can be booth OPEN_LOC and OPEN_PICKUP_LOC.
    if (isOpenPickupLoc) {
      //console.log('DEBUG: isOpenPickupLoc was true');
      return locations;
    }
    if (isOpenLoc) {
      // Only FI, SY, FY, FC users can pickup items at its home/current location, thus return all locations
      if (['FI', 'SY', 'FY', 'FC'].includes(userCategory)) {
        //console.log('DEBUG: isOpenLoc was TRUE and user is FI, SI or FY!');
        return locations;
      } else {
        // Elser filter out the home/current location from available locations

        const homeLocation = entity.get('sublocation.location.id');
        const filteredLocations = [];
        //klona arrayen istället och sätt värdet på kloonen istället för att
        //sätta värdet på referensen till originalobjektet
        ////let newObject = Object.assign({}, oldObject)
        locations.map((item) => {
          item.set('disabled', false);
          const id = item.get('id');
          if (id == homeLocation) {
            item.set('disabled', true);
          }
          filteredLocations.push(item);
        });
        //console.log('DEBUG: isOpenLoc is TRUE! and ordinary patron category.');
        return filteredLocations;
      }
    } else {
      //console.log('DEBUG: isOpenLoc was FALSE!');
      return locations;
    }

  }),

  btnNextDisabled: Ember.computed('order.model.reserve.{location,loanType,subscriptionNotes}', function() {
    let that = this;
    let subscriptionNotesCheck = function() {
      if (that.get('order.model.reserve.biblio.recordType') != 'monograph') {
        if (that.get('order.model.reserve.item')) {
          return true;
        }
        if (that.get('order.model.reserve.subscriptionNotes')) {
          return true;
        }
      } else {
        return true;
      }
      return false;
    }

    if (this.get('order.model.reserve.location') && ((this.get('order.model.reserve.loanType')) || this.get("order.model.reserve.isReservedClicked")) && subscriptionNotesCheck()) {
      return false;
    }
    return true;
  }),

  actions: {
    setLocation(id) {
      if (id != null) {
        let location = this.get('store').peekRecord('location', id);
        this.get('order.model.reserve').set('location', location);
      } else {
        this.get('order.model.reserve').set('location', null);
      }

    },

    setLoanType(id) {
      let loanType = this.get('store').peekRecord('loanType', id);
      this.get('order.model.reserve').set('loanType', loanType);
    },
    moveForward() {
      if (this.get('order.model.reserve.subscription')) {
        this.get('order.model.reserve').set('subscriptionLocation', this.get('order.model.reserve.subscription.sublocation.location.name'));
        this.get('order.model.reserve').set('subscriptionSublocation', this.get('order.model.reserve.subscription.sublocation.name'));
        this.get('order.model.reserve').set('subscriptionSublocationId', this.get('order.model.reserve.subscription.sublocation.id'));
        this.get('order.model.reserve').set('subscriptionCallNumber', this.get('order.model.reserve.subscription.callNumber'));
      }
      this.transitionToRoute('request.order.summary');
    }
  }
});