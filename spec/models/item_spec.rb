require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "methods" do
    context "item can be ordered" do
      it "should return false when rules prevent item from being ordered" do
        item = Item.new(biblio_id: 1, xml: '<datafield tag="952" ind1=" " ind2=" "><subfield code="y">7</subfield></datafield>')
        expect(item.can_be_borrowed).to be_falsey
      end
      it "should return true when rules allow item to be ordered" do
        item = Item.new(biblio_id: 1, xml: '<datafield tag="952" ind1=" " ind2=" "><subfield code="y">1</subfield></datafield>')
        expect(item.can_be_borrowed).to be_truthy
      end
    end

    context "item data can be parsed" do
      before :each do
        @xml = File.open("#{Rails.root}/spec/support/biblio/biblio-1.xml") { |f|
          Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]').to_xml
        }
      end
      it "should return a barcode" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.barcode).to eq('1001821737')
      end
      it "should return an item call numer" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.item_call_number).to eq('Kursbok')
      end
      it "should return an copy number" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.copy_number).to eq('1')
      end
      it "should return an sublocation id" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.sublocation_id).to eq('400004')
      end
      it "should return a due date" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.due_date).to eq('2017-03-02')
      end
    end
  end
end
