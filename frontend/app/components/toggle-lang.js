import Ember from 'ember';

export default Ember.Component.extend({
  i18n: Ember.inject.service(),
  classNames: ['toggle-lang'],

  locales: Ember.computed('i18n.locale', 'i18n.locales', function() {
    const i18n = this.get('i18n');
    return this.get('i18n.locales').map(function (loc) {
      return { id: loc, text: i18n.t('components.toggle-lang.language.' + loc) };
    });
  }),

  didInsertElement: function() {
	$('.selectpicker').selectpicker({
		width: 'fit',
		style: 'btn-primary',
		// some settings availible here see
		// https://silviomoreto.github.io/bootstrap-select/
	});

  },

  actions: {
    setLocale() {
      this.set("lang", this.$('select').val());
      this.set('i18n.locale', this.$('select').val());
    }
  }


});

