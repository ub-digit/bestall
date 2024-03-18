import Oauth2 from 'torii/providers/oauth2-code';
import { configurable } from 'torii/configuration';

export default Oauth2.extend({
  name: 'gub-oauth2',
  baseUrl: 'https://github.com/login/oauth/authorize',
  responseParams: ['code', 'state'],

  redirectUri: configurable('redirectUri', function(){
    // A hack that allows redirectUri to be configurable
    // but default to the superclass
    return this._super();
  }),

  fetch(data) {
    return data;
  }

});
