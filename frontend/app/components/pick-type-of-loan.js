import Ember from 'ember';

export default Ember.Component.extend({

  filteredLoanTypes: Ember.computed('loanTypes', 'item.{itemType,notForLoan}', 'userCategory', function() {

    const itemType = this.get('item.itemType');
    const notForLoan = this.get('item.notForLoan');
    const loanTypes = this.get('loanTypes');
    const userCategory = this.get('userCategory');


    loanTypes.map((type) => {
      type.set('disabled', false);
      if (type.id == 1) { // Home loan / pickup
        if (itemType == '8' || itemType == '17' || notForLoan == '-3') {
          type.set('disabled', true);
        }
      }
    });

    return loanTypes.filter((type) => {
      return ((type.id == 5) ? (['SD', 'FT'].includes(userCategory)) : true);
    });

  }),

  didInsertElement() {
    // First get the filtered list
    const filteredLoanTypes = this.get('filteredLoanTypes');
    const selectedItem = this.get('selectedItem');
    const filteredFromDisabledLoanTypes = filteredLoanTypes.filter(function(item) {if (!item.disabled) {return item}})
    let defaultValue = filteredFromDisabledLoanTypes.get('firstObject').id;

    // Check if anything is selected
    if (selectedItem) {
      // Then check if what is selected is in the filtered list, and if so, keep that selected
      if (filteredLoanTypes.findBy('id', selectedItem)) {
        return;
      }
    }
    // If nothing is selected, or what is selected is not in the list, set a new default value
    this.get('onSelect')(defaultValue);
  }

});
