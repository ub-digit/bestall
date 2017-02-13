import DS from 'ember-data';

export default DS.Model.extend({

  biblio: DS.belongsTo('biblio'),
  // location: DS.belongsTo('location'), // <subfield code="c">400004</subfield>
  itemType: DS.attr('string'),
  itemCallNumber: DS.attr('string'),
  copyNumber: DS.attr('string'),
  barcode: DS.attr('string'),
  status: DS.attr('string')

});


// <datafield tag="952" ind1=" " ind2=" ">
  // <subfield code="0">0</subfield>
  // <subfield code="1">0</subfield>
  // <subfield code="4">0</subfield>
  // <subfield code="7">0</subfield>
  // <subfield code="9">1857418</subfield>
  // <subfield code="a">40</subfield>
  // <subfield code="b">40</subfield>
  // <subfield code="c">400004</subfield>
  // <subfield code="d">2011-09-02</subfield>
  // <subfield code="l">66</subfield>
  // <subfield code="o">Kursbok</subfield>
  // <subfield code="p">1001821737</subfield>
  // <subfield code="q">2015-08-07</subfield>
  // <subfield code="s">2015-06-08</subfield>
  // <subfield code="t">1</subfield>
  // <subfield code="y">2</subfield>
// </datafield>
