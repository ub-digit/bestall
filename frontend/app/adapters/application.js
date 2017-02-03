import DS from 'ember-data';

export default DS.RESTAdapter.extend({
  //namespace: 'api/v1',
  host: 'http://localhost:3000',

  handleResponse(status) {
    if (404 === status) {
      return {status: "404"};
    }
    return this._super(...arguments);
  }
});