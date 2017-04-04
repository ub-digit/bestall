import Ember from 'ember';

export function isActiveTab(params /*, hash*/ ) {

  let tab = params[0];
  let activeTab = params[1];
  if (!activeTab && tab === 'tab1') {
    return 'active';
  }
  if (activeTab && activeTab === tab) {
    return 'active';
  }
  return '';
}

export default Ember.Helper.helper(isActiveTab);