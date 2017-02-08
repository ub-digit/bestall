import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('pick-type-of-loan', 'Integration | Component | pick type of loan', {
  integration: true
});

test('it renders', function(assert) {

  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  this.render(hbs`{{pick-type-of-loan}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#pick-type-of-loan}}
      template block text
    {{/pick-type-of-loan}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
