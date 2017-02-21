import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({
  urlForQueryRecord(query, modelName) {
    let baseUrl = this.buildURL(modelName);
    return `${baseUrl}/current/`;
  }
});
