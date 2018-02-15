import DS from 'ember-data';
import { ActiveModelSerializer } from 'active-model-adapter';

export default ActiveModelSerializer.extend(DS.EmbeddedRecordsMixin, {

  attrs: {
    items: {
      deserialize: 'records'
    },
    subscriptiongroups: {
      deserialize: 'records'
    }

  }

});